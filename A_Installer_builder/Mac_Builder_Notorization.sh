#!/usr/bin/env sh

###############################################################################                                                                                                                                         
# Script Name: create_installer_MultiCI.sh
#
# Description: This script creates an installer for the Fatique audio plugin. It
#              includes logic for packaging AU, VST3, and AAX components, signing,
#              notarization, and final stapling for macOS compatibility.
#
# Author: Thomas Ceyhan (Babelson Audio)
# Email: support@cynicos.com
# Version: 1.1.0
# Company: Babelson Audio
#
# Created: 2025-07-20
# Updated: (add date if script is updated)
#
# Usage: ./create_installer_MultiCI.sh
#
# License: Confidential. All rights reserved to Babelson Audio, 2025.
###############################################################################

set -euo pipefail


# Display ASCII art in the terminal
cat << "EOF"
 _______ .__   __.        __    ______   ____    ____ 
|   ____||  \ |  |       |  |  /  __  \  \   \  /   / 
|  |__   |   \|  |       |  | |  |  |  |  \   \/   /  
|   __|  |  . `  | .--.  |  | |  |  |  |   \_    _/   
|  |____ |  |\   | |  `--'  | |  `--'  |     |  |     
|_______||__| \__|  \______/   \______/      |__|     
                                                      
EOF

echo "-----------------------------------------------"



# Ensure the script has sudo privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (sudo). Please try: sudo ./your_script_name.sh"
  exit 1
fi


   #     <!--+================================================+
   #     |    Check Certificate Expiry and Validity:          |
   #     +==========================+------------------------->
   
 security find-identity -v -p basic

   
   #     <!--+================================================+
   #     |             Project-specific settings              |
   #     +==========================+------------------------->
PROJECT_NAME="MultiCI"
PRODUCT_NAME="Fatique"
BUNDLE_ID="com.babelson.fatique"
DEV_TEAM_ID="H237386G52"  # Replace with your Apple Developer Team ID
# Developer ID and Credentials
DEVELOPER_ID="Developer ID Application: CEYHAN THOMAS UMIT (H237386G52)"  # Replace with your Developer ID Application certificate name.
KEYCHAIN_PROFILE="CEYHAN THOMAS UMIT"
VERSION_FILE="/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/A_Installer_builder/VERSION"
INSTALLER_DIR="/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Installer"



   #     <!--+================================================+
   #     |            Base path setup for plugins             |
   #     +==========================+------------------------->
BASE_PATH="/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/cmake-release/MultiCI_artefacts/Release"
AAX_PLUGIN="${BASE_PATH}/AAX/Fatique.aaxplugin"
AU_PLUGIN="${BASE_PATH}/AU/Fatique.component"
VST3_PLUGIN="${BASE_PATH}/VST3/Fatique.vst3"


   #     <!--+================================================+
   #     |              Destination install paths             |
   #     +==========================+------------------------->
INSTALL_PATH_AAX="/Library/Application Support/Avid/Audio/Plug-Ins"
INSTALL_PATH_AU="/Library/Audio/Plug-Ins/Components"
INSTALL_PATH_VST3="/Library/Audio/Plug-Ins/VST3"

# <============> Helper function for error handling <==========>
handle_error() {
  echo "[Error]: $1"
  exit 1
}



   #     <!--+================================================+
   #     |                  SIGN THE PLUGINS                  |
   #     +==========================+------------------------->
echo "Signing plugins..."

# <============= AAX Plugin Signing (via wraptool and codesign) ==>
echo "Signing AAX Plugin..."
wraptool sign --force --verbose --account "yourpaceaccount" --password "yourPacepassword" --wcguid "GUID" \
--signid "$DEVELOPER_ID" --in "$AAX_PLUGIN" --out "$AAX_PLUGIN"
if [ $? -ne 0 ]; then
  echo "Error during wraptool signing for AAX!"
  exit 1
fi

codesign --force --verify --verbose --sign "$DEVELOPER_ID" --timestamp "$AAX_PLUGIN" || handle_error "Codesigning failed for AAX plugin!"

# AU Plugin Signing
echo "Signing AU Plugin..."
codesign --force --verify --verbose --sign "$DEVELOPER_ID" --timestamp "$AU_PLUGIN" || handle_error "Codesigning failed for AU plugin!"

# VST3 Plugin Signing
echo "Signing VST3 Plugin..."
codesign --force --verify --verbose --sign "$DEVELOPER_ID" --timestamp "$VST3_PLUGIN" || handle_error "Codesigning failed for VST3 plugin!"

echo "All plugins signed successfully!"

# ZIP THE PLUGINS FOR NOTARIZATION
echo "Zipping plugins for notarization..."
ditto -c -k --keepParent "$AAX_PLUGIN" "$AAX_PLUGIN.zip"
ditto -c -k --keepParent "$AU_PLUGIN" "$AU_PLUGIN.zip"
ditto -c -k --keepParent "$VST3_PLUGIN" "$VST3_PLUGIN.zip"

if [ $? -ne 0 ]; then
  echo "Error during zipping plugins!"
  exit 1
fi
echo "Plugins zipped successfully!"


   #     <!--+================================================+
   #     |              NOTARIZE THE PLUGINS                  |
   #     +==========================+------------------------->
echo "Submitting plugins for notarization..."

xcrun notarytool submit "$AAX_PLUGIN.zip" --keychain-profile "$KEYCHAIN_PROFILE" --wait
if [ $? -ne 0 ]; then
  echo "Notarization failed for AAX plugin zip!"
  exit 1
fi

xcrun notarytool submit "$AU_PLUGIN.zip" --keychain-profile "$KEYCHAIN_PROFILE" --wait
if [ $? -ne 0 ]; then
  echo "Notarization failed for AU plugin zip!"
  exit 1
fi

xcrun notarytool submit "$VST3_PLUGIN.zip" --keychain-profile "$KEYCHAIN_PROFILE" --wait
if [ $? -ne 0 ]; then
  echo "Notarization failed for VST3 plugin zip!"
  exit 1
fi

echo "Notarization completed successfully for all plugins!"

# INSTALL PLUGINS
echo "Installing plugins to their respective directories..."
cp -R "$AAX_PLUGIN" "$INSTALL_PATH_AAX/"
if [ $? -ne 0 ]; then
  echo "Failed to install the AAX plugin!"
  exit 1
fi

cp -R "$AU_PLUGIN" "$INSTALL_PATH_AU/"
if [ $? -ne 0 ]; then
  echo "Failed to install the AU plugin!"
  exit 1
fi

cp -R "$VST3_PLUGIN" "$INSTALL_PATH_VST3/"
if [ $? -ne 0 ]; then
  echo "Failed to install the VST3 plugin!"
  exit 1
fi

echo "All plugins installed on your system folders successfully!"


# <==================== Paths for packaging ====================>

VST3_SOURCE_PATH="/Library/Audio/Plug-Ins/VST3/${PRODUCT_NAME}.vst3"
AAX_SOURCE_PATH="/Library/Application Support/Avid/Audio/Plug-Ins/${PRODUCT_NAME}.aaxplugin"
AU_SOURCE_PATH="/Library/Audio/Plug-Ins/Components/${PRODUCT_NAME}.component"

VST3_INSTALL_PATH="/Library/Audio/Plug-Ins/VST3"
AAX_INSTALL_PATH="/Library/Application Support/Avid/Audio/Plug-Ins"
AU_INSTALL_PATH="/Library/Audio/Plug-Ins/Components"

# <==================== Ensure the VERSION file exists==========>

if [ ! -f "$VERSION_FILE" ]; then
    echo "VERSION file is missing, cannot proceed."
    exit 1
fi

# <=================== Prepare installer directory structure ====>

echo "Preparing installer directories..."
rm -rf "${INSTALLER_DIR}/root"
mkdir -p "${INSTALLER_DIR}/resources"


# <=================== Read the version number =================>

VERSION=$(cat "${VERSION_FILE}")
echo "Building installer for: ${PRODUCT_NAME} (version: ${VERSION})"

   #     <!--+================================================+
   #     |             Verify plugin bundles exist            |
   #     +==========================+------------------------->
   
echo "Checking plugin bundles..."
if [ ! -d "${VST3_SOURCE_PATH}" ]; then echo "Missing: ${VST3_SOURCE_PATH}"; exit 1; fi
if [ ! -d "${AAX_SOURCE_PATH}" ]; then echo "Missing: ${AAX_SOURCE_PATH}"; exit 1; fi
if [ ! -d "${AU_SOURCE_PATH}" ]; then echo "Missing: ${AU_SOURCE_PATH}"; exit 1; fi
echo "All plugin bundles found."


   #     <!--+================================================+
   #     |             Check your Code Signature             |
   #     +==========================+------------------------->
   
   echo "Checking code singatures..."
   codesign -display -r - /Library/Audio/Plug-Ins/Components/Fatique.component
   codesign -display -r - /Library/Application\ Support/Avid/Audio/Plug-Ins/Fatique.aaxplugin 
   codesign -display -r - /Library/Audio/Plug-Ins/VST3/Fatique.vst3
   
   
   #     <!--+================================================+
   #     |     Prepare the installer directory structure      |
   #     +==========================+------------------------->
echo "Setting up installer directory structure..."
rm -rf "${INSTALLER_DIR}/root"
mkdir -p "${INSTALLER_DIR}/root"
mkdir -p "${INSTALLER_DIR}/root${VST3_INSTALL_PATH}"
mkdir -p "${INSTALLER_DIR}/root${AAX_INSTALL_PATH}"
mkdir -p "${INSTALLER_DIR}/root${AU_INSTALL_PATH}"


   #     <!--+================================================+
   #     | Copy plugin binaries into installer root structure |
   #     +==========================+------------------------->
echo "Copying plugin binaries..."
cp -R "${VST3_SOURCE_PATH}" "${INSTALLER_DIR}/root${VST3_INSTALL_PATH}"
cp -R "${AAX_SOURCE_PATH}" "${INSTALLER_DIR}/root${AAX_INSTALL_PATH}"
cp -R "${AU_SOURCE_PATH}" "${INSTALLER_DIR}/root${AU_INSTALL_PATH}"

   #     <!--+=========================================+
   #     |   Copy resources into installer directory   |
   #     +==========================+------------------>

echo "Setting up resources..."
mkdir -p "${INSTALLER_DIR}/resources"
cp "/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/A_Installer_builder/welcome.html" "${INSTALLER_DIR}/resources/welcome.html"
cp "/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/A_Installer_builder/LICENSE" "${INSTALLER_DIR}/resources/LICENSE"
cp "/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/A_Installer_builder/conclusion.html" "${INSTALLER_DIR}/resources/conclusion.html"
cp "/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/A_Installer_builder/requirements.xml" "${INSTALLER_DIR}/resources/requirements.xml"

   #     <!--+=========================================+
   #     |      Build separate component packages      |
   #     +==========================+------------------>

echo "Building AU package..."
pkgbuild --root "${AU_SOURCE_PATH}" \
    --identifier "com.babelson.fatique.au" \
    --version "${VERSION}" \
    --install-location "${AU_INSTALL_PATH}" \
    --sign "Developer ID Installer: CEYHAN THOMAS UMIT (H237386G52)" \
    "${INSTALLER_DIR}/Fatique_AU.pkg"

echo "Building AAX package..."
pkgbuild --root "${AAX_SOURCE_PATH}" \
    --identifier "com.babelson.fatique.aax" \
    --version "${VERSION}" \
    --install-location "${AAX_INSTALL_PATH}" \
    --sign "Developer ID Installer: CEYHAN THOMAS UMIT (H237386G52)" \
    "${INSTALLER_DIR}/Fatique_AAX.pkg"

echo "Building VST3 package..."
pkgbuild --root "${VST3_SOURCE_PATH}" \
    --identifier "com.babelson.fatique.vst3" \
    --version "${VERSION}" \
    --install-location "${VST3_INSTALL_PATH}" \
    --sign "Developer ID Installer: CEYHAN THOMAS UMIT (H237386G52)" \
    "${INSTALLER_DIR}/Fatique_VST3.pkg"


# <================= Create the raw component package with `pkgbuild` ==>

echo "Creating the component package (Fatique.pkg)..."
pkgbuild --root "${INSTALLER_DIR}/root" \
  --identifier "${BUNDLE_ID}" \
  --version "${VERSION}" \
  --install-location "/" \
  --sign "${DEV_TEAM_ID}" \
  "${INSTALLER_DIR}/${PRODUCT_NAME}.pkg"
  
  
  # <=============== Copy the logo to the resources directory ========>
  
echo "Copying the installer logo..."
cp /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon_resized.png \
   "${INSTALLER_DIR}/resources/icon.png"
   
 #  sips -Z 64 /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon.png \
     #  --out /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon_resized.png


sips --padToHeightWidth 128 192 --padColor FFFFFF \
     /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon.png \
     --out ${INSTALLER_DIR}/resources/icon_adjusted.png


# <================= Create the distribution.xml ===========>
echo "Creating distribution.xml with logo..."


# <================= Create the raw component package with `pkgbuild` ==>
echo "Creating the component package (Fatique.pkg)..."
pkgbuild --root "${INSTALLER_DIR}/root" \
  --identifier "${BUNDLE_ID}" \
  --version "${VERSION}" \
  --install-location "/" \
  --sign "${DEV_TEAM_ID}" \
  "${INSTALLER_DIR}/${PRODUCT_NAME}.pkg"
  
     #  <!--+=========================================+
     #  | Copy the logo to the resources directory    |
     #  +==========================+------------------>
  
echo "Copying the installer logo..."
cp /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon_resized.png \
   "${INSTALLER_DIR}/resources/icon.png"
   
 #  sips -Z 64 /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon.png \
     #  --out /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon_resized.png


sips --padToHeightWidth 128 192 --padColor FFFFFF \
     /Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Mac_Installer/icon.png \
     --out ${INSTALLER_DIR}/resources/icon_adjusted.png


 	 #  <!--+=========================================+
     #  |         Create the distribution.xml	      |
     #  +==========================+------------------>
     
echo "Creating distribution.xml with logo..."
cat <<EOF > "/Users/thomasceyhan/Documents/GitHub/MultiMeter/multiCI/Installer/distribution.xml"
<?xml version="1.0" encoding="utf-8"?>
	<installer-gui-script minSpecVersion="2">
	<title>${PRODUCT_NAME} Babelson</title>
	<background file="icon.png" scaling="proportional" mime-type="image/png" alignment="bottomleft"/>
	<allowed-os-versions>
    os-version min="10.13"/>
    </allowed-os-versions>

    <welcome file="welcome.html" />
    <license file="LICENSE" />
    <conclusion file="conclusion.html" />

    <options customize="always" require-scripts="false" />
    <choices-outline>
        <line choice="choice_au" />
        <line choice="choice_aax" />
        <line choice="choice_vst3" />
    </choices-outline>

    <choice id="choice_au" title="AU Plugin" description="Install the Audio Unit (AU) plugin">
        <pkg-ref id="com.babelson.fatique.au" />
    </choice>

    <choice id="choice_aax" title="AAX Plugin" description="Install the AAX plugin">
        <pkg-ref id="com.babelson.fatique.aax" />
    </choice>

    <choice id="choice_vst3" title="VST3 Plugin" description="Install the VST3 plugin">
        <pkg-ref id="com.babelson.fatique.vst3" />
    </choice>

    <pkg-ref id="com.babelson.fatique.au" version="${VERSION}" auth="Root">Fatique_AU.pkg</pkg-ref>
    <pkg-ref id="com.babelson.fatique.aax" version="${VERSION}" auth="Root">Fatique_AAX.pkg</pkg-ref>
    <pkg-ref id="com.babelson.fatique.vst3" version="${VERSION}" auth="Root">Fatique_VST3.pkg</pkg-ref>
</installer-gui-script>
EOF

   #     <!--+=========================================+
   #     |                 FINAL BUILD                 |
   #     +==========================+------------------>


# <================ Build the final installer package with choices =======>

FINAL_INSTALLER_PATH="${INSTALLER_DIR}/${PRODUCT_NAME}-${VERSION}.pkg"
echo "Building final installer with productbuild..."
productbuild --distribution "${INSTALLER_DIR}/distribution.xml" \
    --resources "${INSTALLER_DIR}/resources" \
    --package-path "${INSTALLER_DIR}" \
    --sign "Developer ID Installer: CEYHAN THOMAS UMIT (H237386G52)" \
    "${FINAL_INSTALLER_PATH}"

echo "Final Installer created: ${FINAL_INSTALLER_PATH}"

       

# <================= Create the final product package with `productbuild` ======>
echo "Creating the final product installer (Fatique-1.1.0.pkg)..."
productbuild --distribution "${INSTALLER_DIR}/distribution.xml" \
  --resources "${INSTALLER_DIR}/resources" \
  --package-path "${INSTALLER_DIR}" \
  --sign "${DEV_TEAM_ID}" \
  "${INSTALLER_DIR}/${PRODUCT_NAME}-${VERSION}.pkg"

echo "Final Installer created: ${INSTALLER_DIR}/${PRODUCT_NAME}-${VERSION}.pkg"

       
   #     <!--+=========================================+
   #     |                 Notarization                |
   #     +==========================+------------------>
  
USERNAME="umitceyhan@me.com" # Your Apple ID Email
PROFILE_NAME="CEYHAN_THOMAS_UMIT" # Short name for Keychain profile
PKG_PATH="$HOME/Documents/GitHub/MultiMeter/multiCI/Installer/Fatique-1.1.0.pkg"
BUNDLE_ID="com.babelson.Fatique"
RESULT_FILE="$HOME/Documents/GitHub/MultiMeter/multiCI/Installer/notarization.result"


   #     <!--+================================================================================================+
   #     | Store Credentials (Run this once to save credentials in Keychain)                                  |  
   #     |   Only run the following line if credentials haven't been stored yet -- remove it in regular use.  |
   #     +============================================================+---------------------------------------->
   
xcrun notarytool store-credentials --apple-id "$USERNAME" --team-id "H237386G52" --password "yourApplepassword" "$PROFILE_NAME"

# <====================> Validate the .pkg file existence <============>
if [ ! -f "$PKG_PATH" ]; then
    echo "Error: Package at $PKG_PATH does not exist. Aborting."
    exit 1
fi

# <====================> Notarize the Installer Package <==============>
echo "Submitting $PKG_PATH for notarization..."
xcrun notarytool submit "$PKG_PATH" \
    --keychain-profile "$PROFILE_NAME" \
    --wait \
    --output-format json > "$RESULT_FILE"

# <====================> Parse Notarization Result <====================>
REQUEST_UUID=$(jq -r '.id' "$RESULT_FILE")
STATUS=$(jq -r '.status' "$RESULT_FILE")

if [ "$STATUS" != "Accepted" ]; then
    echo "Notarization FAILED for $PKG_PATH. Check the log."
    exit 1
fi

echo "Notarization succeeded with RequestUUID: $REQUEST_UUID"

# <====================> Staple the Ticket to the Package <====================>
echo "Stapling notarization ticket to $PKG_PATH..."
xcrun stapler staple "$PKG_PATH"
if [ $? -ne 0 ]; then
    echo "Stapling FAILED for $PKG_PATH."
    exit 1
fi

echo "Stapling succeeded for $PKG_PATH."
       
