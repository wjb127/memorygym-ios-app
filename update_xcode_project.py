#!/usr/bin/env python3
import os
import uuid
import glob

def generate_uuid():
    """24자리 16진수 UUID 생성"""
    return uuid.uuid4().hex[:24].upper()

def find_swift_files():
    """모든 Swift 파일 찾기"""
    swift_files = []
    for root, dirs, files in os.walk('.'):
        # .xcodeproj 폴더는 제외
        if '.xcodeproj' in root:
            continue
        for file in files:
            if file.endswith('.swift'):
                path = os.path.join(root, file).replace('./', '')
                swift_files.append(path)
    return swift_files

def create_pbxproj():
    """완전한 pbxproj 파일 생성"""
    swift_files = find_swift_files()
    
    # UUID 생성
    uuids = {file: generate_uuid() for file in swift_files}
    build_uuids = {file: generate_uuid() for file in swift_files}
    
    # 기본 UUID들
    project_uuid = "A0FFFFF7"
    target_uuid = "A0FFFFFE"
    app_uuid = "A0FFFFFF"
    products_group = "A1000000"
    main_group = "A0FFFFF6"
    
    # Assets과 Info.plist UUID
    assets_uuid = "A1000004"
    assets_build_uuid = "A1000005"
    preview_assets_uuid = "A1000007"
    preview_build_uuid = "A1000008"
    
    pbxproj_content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
"""
    
    # Swift 파일들의 PBXBuildFile 섹션
    for file in swift_files:
        filename = os.path.basename(file)
        pbxproj_content += f"\t\t{build_uuids[file]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {uuids[file]} /* {filename} */; }};\n"
    
    # Assets 빌드 파일
    pbxproj_content += f"\t\t{assets_build_uuid} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_uuid} /* Assets.xcassets */; }};\n"
    pbxproj_content += f"\t\t{preview_build_uuid} /* Preview Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {preview_assets_uuid} /* Preview Assets.xcassets */; }};\n"
    
    pbxproj_content += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""
    
    # 앱 파일 참조
    pbxproj_content += f"\t\t{app_uuid} /* MemoryGym.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MemoryGym.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
    
    # Swift 파일들의 PBXFileReference 섹션
    for file in swift_files:
        filename = os.path.basename(file)
        pbxproj_content += f"\t\t{uuids[file]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{file}\"; sourceTree = \"<group>\"; }};\n"
    
    # Assets 파일 참조
    pbxproj_content += f"\t\t{assets_uuid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};\n"
    pbxproj_content += f"\t\t{preview_assets_uuid} /* Preview Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = \"Preview Assets.xcassets\"; sourceTree = \"<group>\"; }};\n"
    pbxproj_content += f"\t\tA1000009 /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};\n"
    
    pbxproj_content += """/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A0FFFFFC /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
"""
    
    # 메인 그룹
    pbxproj_content += f"""\t\t{main_group} = {{
			isa = PBXGroup;
			children = (
				A1000001 /* MemoryGym */,
				{products_group} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{products_group} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{app_uuid} /* MemoryGym.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		A1000001 /* MemoryGym */ = {{
			isa = PBXGroup;
			children = (
"""
    
    # Swift 파일들을 그룹에 추가
    for file in swift_files:
        filename = os.path.basename(file)
        pbxproj_content += f"\t\t\t\t{uuids[file]} /* {filename} */,\n"
    
    pbxproj_content += f"""\t\t\t\t{assets_uuid} /* Assets.xcassets */,
				A1000009 /* Info.plist */,
				A1000006 /* Preview Content */,
			);
			path = MemoryGym;
			sourceTree = "<group>";
		}};
		A1000006 /* Preview Content */ = {{
			isa = PBXGroup;
			children = (
				{preview_assets_uuid} /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{target_uuid} /* MemoryGym */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = A100000D /* Build configuration list for PBXNativeTarget "MemoryGym" */;
			buildPhases = (
				A0FFFFFB /* Sources */,
				A0FFFFFC /* Frameworks */,
				A0FFFFFD /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MemoryGym;
			productName = MemoryGym;
			productReference = {app_uuid} /* MemoryGym.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{project_uuid} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {{
					{target_uuid} = {{
						CreatedOnToolsVersion = 15.0;
					}};
				}};
			}};
			buildConfigurationList = A0FFFFFA /* Build configuration list for PBXProject "MemoryGym" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = ko;
			hasScannedForEncodings = 0;
			knownRegions = (
				ko,
				Base,
			);
			mainGroup = {main_group};
			productRefGroup = {products_group} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{target_uuid} /* MemoryGym */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A0FFFFFD /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{preview_build_uuid} /* Preview Assets.xcassets in Resources */,
				{assets_build_uuid} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A0FFFFFB /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
"""
    
    # Swift 파일들을 Sources에 추가
    for file in swift_files:
        filename = os.path.basename(file)
        pbxproj_content += f"\t\t\t\t{build_uuids[file]} /* {filename} in Sources */,\n"
    
    pbxproj_content += """\t\t\t);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A100000B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_framework_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		A100000C /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		A100000E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\\"Preview Content\\"";
				DEVELOPMENT_TEAM = "9Q26686S8R";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.memorygym.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		A100000F /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\\"Preview Content\\"";
				DEVELOPMENT_TEAM = "9Q26686S8R";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.memorygym.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A0FFFFFA /* Build configuration list for PBXProject "MemoryGym" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A100000B /* Debug */,
				A100000C /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A100000D /* Build configuration list for PBXNativeTarget "MemoryGym" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A100000E /* Debug */,
				A100000F /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	}};
	rootObject = {project_uuid} /* Project object */;
}}"""
    
    return pbxproj_content

if __name__ == "__main__":
    print("🔧 Xcode 프로젝트 파일 자동 생성 중...")
    
    # Swift 파일들 찾기
    swift_files = find_swift_files()
    print(f"📁 발견된 Swift 파일: {len(swift_files)}개")
    for file in swift_files:
        print(f"   - {file}")
    
    # pbxproj 파일 생성
    pbxproj_content = create_pbxproj()
    
    # 파일 저장
    with open('MemoryGym.xcodeproj/project.pbxproj', 'w') as f:
        f.write(pbxproj_content)
    
    print("✅ Xcode 프로젝트 파일 업데이트 완료!")
    print("📱 이제 다음 명령어로 빌드할 수 있습니다:")
    print("   xcodebuild -project MemoryGym.xcodeproj -scheme MemoryGym -destination 'platform=iOS,name=WiPhone' build") 