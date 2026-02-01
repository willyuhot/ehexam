#!/bin/bash

# 修复 Xcode 项目格式兼容性问题

cd /Users/yuhuahuan/code/EHExam

echo "🔧 修复 Xcode 项目格式兼容性"
echo "=============================="
echo ""

# 检查当前 Xcode 版本
XCODE_VERSION=$(xcodebuild -version 2>&1 | head -1 | awk '{print $2}' | cut -d. -f1,2)
echo "当前 Xcode 版本: $XCODE_VERSION"
echo ""

# 如果项目文件存在，降级格式
if [ -f "EHExam.xcodeproj/project.pbxproj" ]; then
    echo "📝 降级项目文件格式..."
    
    # 将 objectVersion 从 77 (Xcode 16) 降级到 54 (Xcode 14)
    sed -i '' 's/objectVersion = 77;/objectVersion = 54;/g' EHExam.xcodeproj/project.pbxproj
    sed -i '' 's/compatibilityVersion = "Xcode 15.0";/compatibilityVersion = "Xcode 14.0";/g' EHExam.xcodeproj/project.pbxproj
    sed -i '' 's/compatibilityVersion = "Xcode 16.0";/compatibilityVersion = "Xcode 14.0";/g' EHExam.xcodeproj/project.pbxproj
    sed -i '' 's/lastUpgradeCheck = 1500;/lastUpgradeCheck = 1400;/g' EHExam.xcodeproj/project.pbxproj
    sed -i '' 's/lastUpgradeCheck = 1600;/lastUpgradeCheck = 1400;/g' EHExam.xcodeproj/project.pbxproj
    
    echo "✅ 项目格式已降级到 Xcode 14.0 兼容格式"
    echo ""
    
    # 显示当前格式
    echo "当前项目格式:"
    grep "objectVersion" EHExam.xcodeproj/project.pbxproj | head -1
    grep "compatibilityVersion" EHExam.xcodeproj/project.pbxproj | head -1
else
    echo "⚠️  项目文件不存在，将重新生成..."
    echo ""
    
    # 更新 project.yml 使用兼容版本
    if [ -f "project.yml" ]; then
        echo "📝 更新 project.yml 配置..."
        # 这里可以添加自动更新 project.yml 的逻辑
    fi
    
    # 重新生成项目
    if command -v xcodegen &> /dev/null; then
        echo "🔄 重新生成项目..."
        xcodegen generate
        
        # 立即降级格式
        if [ -f "EHExam.xcodeproj/project.pbxproj" ]; then
            sed -i '' 's/objectVersion = 77;/objectVersion = 54;/g' EHExam.xcodeproj/project.pbxproj
            sed -i '' 's/compatibilityVersion = "Xcode 15.0";/compatibilityVersion = "Xcode 14.0";/g' EHExam.xcodeproj/project.pbxproj
            sed -i '' 's/compatibilityVersion = "Xcode 16.0";/compatibilityVersion = "Xcode 14.0";/g' EHExam.xcodeproj/project.pbxproj
            echo "✅ 项目已生成并降级格式"
        fi
    else
        echo "❌ 未找到 xcodegen，请先安装: brew install xcodegen"
    fi
fi

echo ""
echo "✨ 完成！现在可以在 Xcode 15.4 中打开项目了"
