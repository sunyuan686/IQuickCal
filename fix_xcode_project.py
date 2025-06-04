#!/usr/bin/env python3

import os
import re
import uuid
import shutil

def generate_uuid():
    """Generate a unique 24-character hex string for Xcode"""
    return uuid.uuid4().hex.upper()[:24]

def add_swift_files_to_xcode_project():
    project_dir = "/Users/sunyuan/develop/project/ios/IQuickCal"
    pbxproj_path = os.path.join(project_dir, "IQuickCal.xcodeproj", "project.pbxproj")
    
    # Create backup
    backup_path = pbxproj_path + ".backup2"
    shutil.copy2(pbxproj_path, backup_path)
    print(f"Created backup: {backup_path}")
    
    # Define all Swift files to add
    swift_files = [
        "Models/QuestionType.swift",
        "Models/Question.swift", 
        "Models/PracticeSession.swift",
        "Models/Answer.swift",
        "Models/WrongAnswer.swift",
        "Models/UserPreferences.swift",
        "Services/QuestionGenerator.swift",
        "Services/PracticeManager.swift",
        "Views/MainTabView.swift",
        "Views/HomeView.swift",
        "Views/PracticeView.swift",
        "Views/ResultView.swift",
        "Views/HistoryView.swift",
        "Views/MistakesView.swift",
        "Views/SettingsView.swift"
    ]
    
    # Verify all files exist
    missing_files = []
    for file_path in swift_files:
        full_path = os.path.join(project_dir, "IQuickCal", file_path)
        if not os.path.exists(full_path):
            missing_files.append(full_path)
    
    if missing_files:
        print("ERROR: Missing files:")
        for file_path in missing_files:
            print(f"  {file_path}")
        return False
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for all files
    file_uuids = {}
    build_file_uuids = {}
    
    for file_path in swift_files:
        file_uuids[file_path] = generate_uuid()
        build_file_uuids[file_path] = generate_uuid()
    
    # Generate group UUIDs
    models_group_uuid = generate_uuid()
    services_group_uuid = generate_uuid()
    views_group_uuid = generate_uuid()
    
    # 1. Add PBXBuildFile entries
    build_file_section = "/* Begin PBXBuildFile section */"
    build_file_entries = []
    
    for file_path in swift_files:
        filename = os.path.basename(file_path)
        entry = f"\t\t{build_file_uuids[file_path]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuids[file_path]} /* {filename} */; }};"
        build_file_entries.append(entry)
    
    # Find where to insert build file entries
    build_file_end = content.find("/* End PBXBuildFile section */")
    if build_file_end == -1:
        print("ERROR: Could not find PBXBuildFile section")
        return False
    
    # Insert before the end
    build_file_content = '\n'.join(build_file_entries) + '\n'
    content = content[:build_file_end] + build_file_content + '\t\t' + content[build_file_end:]
    
    # 2. Add PBXFileReference entries
    file_ref_section = "/* Begin PBXFileReference section */"
    file_ref_entries = []
    
    for file_path in swift_files:
        filename = os.path.basename(file_path)
        entry = f"\t\t{file_uuids[file_path]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};"
        file_ref_entries.append(entry)
    
    # Find where to insert file reference entries
    file_ref_end = content.find("/* End PBXFileReference section */")
    if file_ref_end == -1:
        print("ERROR: Could not find PBXFileReference section")
        return False
    
    # Insert before the end
    file_ref_content = '\n'.join(file_ref_entries) + '\n'
    content = content[:file_ref_end] + file_ref_content + '\t\t' + content[file_ref_end:]
    
    # 3. Add PBXGroup entries for folder structure
    group_section = "/* Begin PBXGroup section */"
    
    # Find the main IQuickCal group (look for the group that contains ContentView.swift)
    main_group_pattern = r'([A-F0-9]{24}) \/\* IQuickCal \*\/ = \{[^}]+children = \(([^)]+)\);'
    main_group_match = re.search(main_group_pattern, content, re.DOTALL)
    
    if not main_group_match:
        print("ERROR: Could not find main IQuickCal group")
        return False
    
    main_group_uuid = main_group_match.group(1)
    main_group_children = main_group_match.group(2)
    
    # Add folder groups to main group children
    new_children = f"{main_group_children.rstrip()}\n\t\t\t\t{models_group_uuid} /* Models */,\n\t\t\t\t{services_group_uuid} /* Services */,\n\t\t\t\t{views_group_uuid} /* Views */,"
    
    # Replace the main group children
    content = content.replace(main_group_children, new_children)
    
    # Create folder group entries
    group_entries = []
    
    # Models group
    models_children = []
    services_children = []
    views_children = []
    
    for file_path in swift_files:
        filename = os.path.basename(file_path)
        if file_path.startswith("Models/"):
            models_children.append(f"\t\t\t\t{file_uuids[file_path]} /* {filename} */,")
        elif file_path.startswith("Services/"):
            services_children.append(f"\t\t\t\t{file_uuids[file_path]} /* {filename} */,")
        elif file_path.startswith("Views/"):
            views_children.append(f"\t\t\t\t{file_uuids[file_path]} /* {filename} */,")
    
    # Models group
    models_entry = f"""\t\t{models_group_uuid} /* Models */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(models_children)}
\t\t\t);
\t\t\tpath = Models;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    
    # Services group
    services_entry = f"""\t\t{services_group_uuid} /* Services */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(services_children)}
\t\t\t);
\t\t\tpath = Services;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    
    # Views group
    views_entry = f"""\t\t{views_group_uuid} /* Views */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(views_children)}
\t\t\t);
\t\t\tpath = Views;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    
    group_entries = [models_entry, services_entry, views_entry]
    
    # Find where to insert group entries
    group_end = content.find("/* End PBXGroup section */")
    if group_end == -1:
        print("ERROR: Could not find PBXGroup section")
        return False
    
    # Insert before the end
    group_content = '\n'.join(group_entries) + '\n'
    content = content[:group_end] + group_content + '\t\t' + content[group_end:]
    
    # 4. Add to Sources build phase
    sources_pattern = r'([A-F0-9]{24}) \/\* Sources \*\/ = \{[^}]+files = \(([^)]+)\);'
    sources_match = re.search(sources_pattern, content, re.DOTALL)
    
    if not sources_match:
        print("ERROR: Could not find Sources build phase")
        return False
    
    sources_files = sources_match.group(2)
    
    # Add our build file references
    new_sources = []
    for file_path in swift_files:
        filename = os.path.basename(file_path)
        new_sources.append(f"\t\t\t\t{build_file_uuids[file_path]} /* {filename} in Sources */,")
    
    new_sources_content = f"{sources_files.rstrip()}\n" + '\n'.join(new_sources)
    content = content.replace(sources_files, new_sources_content)
    
    # Write the modified content back
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("Successfully added Swift files to Xcode project:")
    for file_path in swift_files:
        print(f"  ✓ {file_path}")
    
    return True

if __name__ == "__main__":
    success = add_swift_files_to_xcode_project()
    if success:
        print("\n🎉 All Swift files have been added to the Xcode project!")
        print("You can now build the project successfully.")
    else:
        print("\n❌ Failed to add Swift files to Xcode project.")
