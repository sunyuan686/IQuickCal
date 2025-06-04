#!/usr/bin/env python3

import re
import uuid
import os

# List of new Swift files to add
NEW_FILES = [
    "IQuickCal/Models/QuestionType.swift",
    "IQuickCal/Models/Question.swift", 
    "IQuickCal/Models/PracticeSession.swift",
    "IQuickCal/Models/Answer.swift",
    "IQuickCal/Models/WrongAnswer.swift",
    "IQuickCal/Models/UserPreferences.swift",
    "IQuickCal/Services/QuestionGenerator.swift",
    "IQuickCal/Services/PracticeManager.swift",
    "IQuickCal/Views/MainTabView.swift",
    "IQuickCal/Views/HomeView.swift",
    "IQuickCal/Views/PracticeView.swift",
    "IQuickCal/Views/ResultView.swift",
    "IQuickCal/Views/HistoryView.swift",
    "IQuickCal/Views/MistakesView.swift",
    "IQuickCal/Views/SettingsView.swift"
]

def generate_uuid():
    """Generate a 24-character hex string for Xcode UUIDs"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_files_to_xcode_project():
    project_file = "IQuickCal.xcodeproj/project.pbxproj"
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for all new files
    file_uuids = {}
    build_uuids = {}
    
    for file_path in NEW_FILES:
        file_uuids[file_path] = generate_uuid()
        build_uuids[file_path] = generate_uuid()
    
    # 1. Add PBXBuildFile entries
    build_file_section = "/* Begin PBXBuildFile section */"
    build_entries = []
    
    for file_path in NEW_FILES:
        filename = os.path.basename(file_path)
        build_entry = f"\t\t{build_uuids[file_path]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuids[file_path]} /* {filename} */; }};"
        build_entries.append(build_entry)
    
    # Find the end of PBXBuildFile section
    build_end_pattern = r"(/* End PBXBuildFile section */)"
    build_section_content = "\n".join(build_entries) + "\n"
    content = re.sub(build_end_pattern, build_section_content + r"\1", content)
    
    # 2. Add PBXFileReference entries
    file_ref_section_end = "/* End PBXFileReference section */"
    file_ref_entries = []
    
    for file_path in NEW_FILES:
        filename = os.path.basename(file_path)
        file_ref_entry = f"\t\t{file_uuids[file_path]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};"
        file_ref_entries.append(file_ref_entry)
    
    file_ref_content = "\n".join(file_ref_entries) + "\n"
    content = content.replace(file_ref_section_end, file_ref_content + file_ref_section_end)
    
    # 3. Add files to the main group
    # Find the IQuickCal group and add our folders
    iquickcal_group_pattern = r"(AAC97F582DF0183700B007D3 /\* IQuickCal \*/ = \{[^}]+children = \([^)]+)"
    
    # Add folder references
    models_uuid = generate_uuid()
    services_uuid = generate_uuid() 
    views_uuid = generate_uuid()
    
    group_additions = f"\n\t\t\t\t{models_uuid} /* Models */,\n\t\t\t\t{services_uuid} /* Services */,\n\t\t\t\t{views_uuid} /* Views */,"
    
    content = re.sub(iquickcal_group_pattern, r"\1" + group_additions, content)
    
    # 4. Add the folder groups
    group_section_end = "/* End PBXGroup section */"
    
    models_files = [f for f in NEW_FILES if "Models" in f]
    services_files = [f for f in NEW_FILES if "Services" in f]
    views_files = [f for f in NEW_FILES if "Views" in f]
    
    group_entries = []
    
    # Models group
    models_children = ",\n".join([f"\t\t\t\t{file_uuids[f]} /* {os.path.basename(f)} */" for f in models_files])
    models_group = f"""		{models_uuid} /* Models */ = {{
			isa = PBXGroup;
			children = (
{models_children},
			);
			path = Models;
			sourceTree = "<group>";
		}};"""
    group_entries.append(models_group)
    
    # Services group
    services_children = ",\n".join([f"\t\t\t\t{file_uuids[f]} /* {os.path.basename(f)} */" for f in services_files])
    services_group = f"""		{services_uuid} /* Services */ = {{
			isa = PBXGroup;
			children = (
{services_children},
			);
			path = Services;
			sourceTree = "<group>";
		}};"""
    group_entries.append(services_group)
    
    # Views group
    views_children = ",\n".join([f"\t\t\t\t{file_uuids[f]} /* {os.path.basename(f)} */" for f in views_files])
    views_group = f"""		{views_uuid} /* Views */ = {{
			isa = PBXGroup;
			children = (
{views_children},
			);
			path = Views;
			sourceTree = "<group>";
		}};"""
    group_entries.append(views_group)
    
    group_content = "\n".join(group_entries) + "\n"
    content = content.replace(group_section_end, group_content + group_section_end)
    
    # 5. Add files to build phases
    sources_build_phase_pattern = r"(isa = PBXSourcesBuildPhase;[^}]+files = \([^)]+)"
    
    source_build_entries = ",\n".join([f"\t\t\t\t{build_uuids[f]} /* {os.path.basename(f)} in Sources */" for f in NEW_FILES])
    source_build_content = f",\n{source_build_entries}"
    
    content = re.sub(sources_build_phase_pattern, r"\1" + source_build_content, content)
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("Successfully added files to Xcode project!")
    print(f"Added {len(NEW_FILES)} Swift files")

if __name__ == "__main__":
    add_files_to_xcode_project()
