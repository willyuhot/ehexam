# 项目清理指南

## 🗑️ 可以安全删除的文件

### 1. **备份文件 (.bak)**
这些是备份文件，可以安全删除：
- `create_icon_image.swift.bak` - 图标生成脚本的备份
- `project.yml.bak` - 项目配置的备份

### 2. **构建产物**
这些是构建生成的文件，可以重新构建：
- `build/` 目录 (约 70MB) - 包含所有构建中间文件和产物
- `EHExam.ipa` (约 1.4MB) - 打包的应用文件

### 3. **临时脚本（可选）**
- `create_icon_image.swift` - 用于生成图标的临时脚本，图标已生成，可以删除

### 4. **Xcode 用户数据（可选）**
- `EHExam.xcodeproj/project.xcworkspace/xcuserdata/` - 个人 Xcode 设置，删除不影响项目

## 🚫 不要删除的文件

### 核心项目文件
- `project.yml` - 项目配置文件（**重要**）
- `Info.plist` - 应用信息配置
- `EHExamApp.swift` - 应用入口
- `Models/`, `Views/`, `Services/`, `ViewModels/` - 源代码目录
- `Assets.xcassets/` - 资源文件
- `resources/` - 题目数据文件

### 文档文件
- `*.md` - 所有 Markdown 文档（README、指南等）

### 构建脚本
- `build_*.sh` - 构建脚本
- `install_*.sh` - 安装脚本
- `fix_*.sh` - 修复脚本
- `upload_to_testflight.sh` - 上传脚本

## 🧹 快速清理

### 方法1：使用清理脚本（推荐）
```bash
./cleanup_project.sh
```

脚本会：
1. 自动删除所有 `.bak` 备份文件
2. 删除 `build/` 目录
3. 删除 `EHExam.ipa`
4. 询问是否删除临时脚本和用户数据

### 方法2：手动清理

#### 删除备份文件
```bash
rm -f *.bak create_icon_image.swift.bak project.yml.bak
```

#### 删除构建产物
```bash
rm -rf build/
rm -f EHExam.ipa
```

#### 删除临时脚本（可选）
```bash
rm -f create_icon_image.swift
```

#### 删除 Xcode 用户数据（可选）
```bash
rm -rf EHExam.xcodeproj/project.xcworkspace/xcuserdata
```

## 📊 清理效果

清理后可以释放约 **70-80MB** 空间（主要是 build 目录）。

## ⚠️ 注意事项

1. **构建产物可以重新生成**：删除 `build/` 和 `.ipa` 后，运行 `./build_for_testflight.sh` 可以重新构建
2. **备份文件**：如果使用 Git，可以从历史记录恢复 `.bak` 文件
3. **用户数据**：删除 `xcuserdata` 会清除个人 Xcode 设置，但不会影响项目功能

## 🔄 重新构建

清理后如果需要重新构建：
```bash
# 构建 IPA
./build_for_testflight.sh

# 或直接安装到设备
./build_and_install.sh
```
