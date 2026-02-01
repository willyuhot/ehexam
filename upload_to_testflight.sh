#!/bin/bash
# 上传到TestFlight（需要API Key）

set -e

PROJECT_DIR="/Users/yuhuahuan/code/EHExam"
cd "$PROJECT_DIR"

IPA_FILE="./EHExam.ipa"

if [ ! -f "$IPA_FILE" ]; then
    echo "❌ 未找到IPA文件: $IPA_FILE"
    echo "   请先运行 ./build_for_testflight.sh 构建IPA"
    exit 1
fi

echo "📤 上传到TestFlight..."
echo ""

# 检查API Key配置
if [ -z "$API_KEY" ] || [ -z "$API_ISSUER" ]; then
    echo "⚠️  需要配置API Key和Issuer ID"
    echo ""
    echo "💡 获取API Key的正确步骤："
    echo "   1. 登录 https://appstoreconnect.apple.com"
    echo "   2. 点击右上角的用户图标（你的名字）"
    echo "   3. 选择 'Users and Access'（用户和访问权限）"
    echo "   4. 点击左侧的 'Keys'（密钥）标签"
    echo "   5. 点击 '+' 创建新的API Key"
    echo "   6. 下载.p8文件（只能下载一次！请妥善保存）"
    echo "   7. 记录 Key ID 和 Issuer ID（Issuer ID在页面顶部，是UUID格式）"
    echo ""
    echo "💡 更简单的方法：使用 Transporter 应用（不需要API Key）"
    echo "   1. 从 Mac App Store 下载 'Transporter' 应用"
    echo "   2. 打开 Transporter，拖拽 IPA 文件进去"
    echo "   3. 点击'交付'即可"
    echo ""
    read -p "请输入API Key ID: " KEY_ID
    read -p "请输入Issuer ID: " ISSUER_ID
    read -p "请输入.p8文件路径: " P8_FILE
    
    export API_KEY="$KEY_ID"
    export API_ISSUER="$ISSUER_ID"
    export P8_FILE_PATH="$P8_FILE"
fi

# 使用xcrun altool上传
echo "正在上传..."
xcrun altool --upload-app \
    --type ios \
    --file "$IPA_FILE" \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER" \
    --verbose

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 上传成功！"
    echo ""
    echo "📱 在App Store Connect中："
    echo "   1. 进入你的App"
    echo "   2. 进入TestFlight标签"
    echo "   3. 等待处理完成（通常需要几分钟）"
    echo "   4. 添加测试员或内部测试"
else
    echo ""
    echo "❌ 上传失败"
    echo ""
    echo "💡 如果使用.p8文件，可以使用以下命令："
    echo "   xcrun altool --upload-app --type ios --file $IPA_FILE \\"
    echo "     --apiKey \$API_KEY --apiIssuer \$API_ISSUER \\"
    echo "     --verbose"
fi
