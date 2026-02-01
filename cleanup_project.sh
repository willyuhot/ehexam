#!/bin/bash

# 清理项目中的垃圾文件

cd /Users/yuhuahuan/code/EHExam

echo "🧹 清理项目垃圾文件"
echo "=================="
echo ""

# 统计清理前的空间
BEFORE=$(du -sh . 2>/dev/null | awk '{print $1}')

echo "清理前的项目大小: $BEFORE"
echo ""

# 1. 删除备份文件
echo "📁 删除备份文件..."
rm -f *.bak
rm -f create_icon_image.swift.bak
rm -f project.yml.bak
echo "✅ 备份文件已删除"
echo ""

# 2. 删除构建产物
echo "📦 删除构建产物..."
if [ -d "build" ]; then
    BUILD_SIZE=$(du -sh build 2>/dev/null | awk '{print $1}')
    echo "   删除 build/ 目录 (大小: $BUILD_SIZE)"
    rm -rf build/
    echo "✅ build/ 目录已删除"
fi

if [ -f "EHExam.ipa" ]; then
    IPA_SIZE=$(du -sh EHExam.ipa 2>/dev/null | awk '{print $1}')
    echo "   删除 EHExam.ipa (大小: $IPA_SIZE)"
    rm -f EHExam.ipa
    echo "✅ EHExam.ipa 已删除"
fi
echo ""

# 3. 删除临时脚本（可选）
echo "📝 检查临时脚本..."
if [ -f "create_icon_image.swift" ]; then
    echo "   发现 create_icon_image.swift（图标已生成，可删除）"
    read -p "   是否删除 create_icon_image.swift? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f create_icon_image.swift
        echo "✅ create_icon_image.swift 已删除"
    else
        echo "⏭️  保留 create_icon_image.swift"
    fi
fi
echo ""

# 4. 清理 Xcode 用户数据（可选）
echo "🔧 检查 Xcode 用户数据..."
if [ -d "EHExam.xcodeproj/project.xcworkspace/xcuserdata" ]; then
    echo "   发现 xcuserdata 目录（个人设置，可删除）"
    read -p "   是否删除 xcuserdata? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf EHExam.xcodeproj/project.xcworkspace/xcuserdata
        echo "✅ xcuserdata 已删除"
    else
        echo "⏭️  保留 xcuserdata"
    fi
fi
echo ""

# 统计清理后的空间
AFTER=$(du -sh . 2>/dev/null | awk '{print $1}')

echo "=================="
echo "清理完成！"
echo "清理前: $BEFORE"
echo "清理后: $AFTER"
echo ""
echo "💡 提示："
echo "   - 构建产物已删除，需要时运行 ./build_for_testflight.sh 重新构建"
echo "   - 备份文件已删除，如有需要可从 Git 历史恢复"
