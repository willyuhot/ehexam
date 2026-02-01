#!/bin/bash
# 构建TestFlight版本

set -e

PROJECT_DIR="/Users/yuhuahuan/code/EHExam"
cd "$PROJECT_DIR"

echo "🚀 构建TestFlight版本..."
echo ""

# 检查必要的配置
if [ -z "$DEVELOPMENT_TEAM" ]; then
    echo "⚠️  请设置开发团队ID："
    echo "   export DEVELOPMENT_TEAM='你的Team ID'"
    echo ""
    echo "💡 获取Team ID的方法："
    echo "   1. 登录 https://developer.apple.com/account"
    echo "   2. 在Membership页面查看Team ID"
    echo ""
    read -p "请输入你的Team ID（或按Ctrl+C取消）: " TEAM_ID
    export DEVELOPMENT_TEAM="$TEAM_ID"
fi

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf build
rm -rf *.ipa
rm -rf Payload

# 重新生成项目（如果需要）并修复格式
if [ ! -d "EHExam.xcodeproj" ] || [ ! -f "EHExam.xcodeproj/project.pbxproj" ]; then
    echo "📦 生成Xcode项目..."
    xcodegen generate
    # 修复项目格式兼容性
    if [ -f "fix_xcode_version.sh" ]; then
        ./fix_xcode_version.sh 2>&1 | grep -E "✅|完成" || true
    else
        sed -i '' 's/objectVersion = 77/objectVersion = 54/g' EHExam.xcodeproj/project.pbxproj 2>/dev/null || true
        sed -i '' 's/compatibilityVersion = "Xcode 15.0"/compatibilityVersion = "Xcode 14.0"/g' EHExam.xcodeproj/project.pbxproj 2>/dev/null || true
        sed -i '' 's/compatibilityVersion = "Xcode 16.0"/compatibilityVersion = "Xcode 14.0"/g' EHExam.xcodeproj/project.pbxproj 2>/dev/null || true
    fi
fi

# 构建Archive
echo ""
echo "📱 构建Archive（Release配置）..."
xcodebuild clean archive \
    -project EHExam.xcodeproj \
    -scheme EHExam \
    -configuration Release \
    -archivePath ./build/EHExam.xcarchive \
    -sdk iphoneos \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    -allowProvisioningUpdates

if [ ! -d "./build/EHExam.xcarchive" ]; then
    echo "❌ Archive构建失败"
    exit 1
fi

echo "✅ Archive构建成功"

# 导出IPA
echo ""
echo "📦 导出IPA文件..."

# 创建ExportOptions.plist
cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$DEVELOPMENT_TEAM</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath ./build/EHExam.xcarchive \
    -exportPath ./build/export \
    -exportOptionsPlist ExportOptions.plist \
    -allowProvisioningUpdates

# 查找生成的IPA
IPA_FILE=$(find ./build/export -name "*.ipa" | head -1)

if [ -z "$IPA_FILE" ]; then
    echo "❌ IPA导出失败"
    exit 1
fi

# 复制IPA到项目根目录
cp "$IPA_FILE" ./EHExam.ipa

echo ""
echo "✅ TestFlight版本构建完成！"
echo ""
echo "📦 IPA文件位置: $(pwd)/EHExam.ipa"
echo ""
echo "📤 上传到TestFlight的步骤："
echo "   1. 登录 https://appstoreconnect.apple.com"
echo "   2. 进入你的App（如果没有，需要先创建）"
echo "   3. 进入TestFlight标签"
echo "   4. 点击 '+' 添加新构建"
echo "   5. 使用Transporter应用或xcrun altool上传IPA文件"
echo ""
echo "💡 或者使用命令行上传："
echo "   xcrun altool --upload-app --type ios --file ./EHExam.ipa --apiKey YOUR_API_KEY --apiIssuer YOUR_ISSUER_ID"
echo ""
