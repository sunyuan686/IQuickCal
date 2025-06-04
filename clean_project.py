#!/usr/bin/env python3
"""
清理Xcode项目文件，移除不存在的文件引用
"""

import os
import sys
import re

def clean_xcode_project():
    project_file = "IQuickCal.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print("❌ 项目文件不存在：" + project_file)
        return False
    
    print("🧹 开始清理项目文件...")
    
    # 读取项目文件
    with open(project_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 移除所有与Item.swift相关的引用
    print("  📝 移除Item.swift相关引用...")
    
    # 移除文件引用行
    content = re.sub(r'.*Item\.swift.*\n', '', content)
    
    # 移除可能的重复条目和无效引用
    print("  🔧 清理重复条目...")
    
    # 移除Asset catalog的重复引用（从编译错误信息看到的问题）
    lines = content.split('\n')
    seen_assets = set()
    clean_lines = []
    
    for line in lines:
        # 检查是否是资产目录相关的行
        if 'Assets.xcassets' in line or 'Preview Assets.xcassets' in line:
            line_key = line.strip()
            if line_key in seen_assets:
                print(f"    ⚠️  移除重复行: {line_key[:50]}...")
                continue
            seen_assets.add(line_key)
        clean_lines.append(line)
    
    content = '\n'.join(clean_lines)
    
    # 检查是否有变化
    if content != original_content:
        # 创建备份
        backup_file = project_file + ".backup2"
        with open(backup_file, 'w', encoding='utf-8') as f:
            f.write(original_content)
        print(f"  💾 已创建备份: {backup_file}")
        
        # 写入清理后的内容
        with open(project_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ 项目文件清理完成！")
        return True
    else:
        print("ℹ️  项目文件无需清理")
        return True

def main():
    if not clean_xcode_project():
        sys.exit(1)
    
    print("\n🚀 重新尝试编译...")
    
    # 尝试重新编译
    exit_code = os.system("xcodebuild -project IQuickCal.xcodeproj -scheme IQuickCal -destination 'platform=iOS Simulator,name=iPhone 15' clean build")
    
    if exit_code == 0:
        print("\n🎉 项目编译成功！")
    else:
        print("\n❌ 项目仍有编译问题，请在Xcode中手动检查")

if __name__ == "__main__":
    main()
