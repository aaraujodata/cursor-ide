//
//  CourseDetailTabsView.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import SwiftUI

/// Tab selection enum for course detail tabs
enum CourseDetailTab: String, CaseIterable {
    case syllabus = "Syllabus"
    case about = "About"
}

/// Tab view component for course detail (Syllabus/About)
struct CourseDetailTabsView: View {
    @Binding var selectedTab: CourseDetailTab
    let course: Course

    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            tabSelector

            // Tab content
            tabContent
        }
        .background(Color.cardBackground)
        .cornerRadius(Radius.radiusLarge)
        .padding(.horizontal, Spacing.spacing4)
        .padding(.top, Spacing.spacing4)
        .onAppear {
            // DEBUG: Log tab view state
            print("📑 [CourseDetailTabsView] Tab view appeared:")
            print("   - Selected tab: \(selectedTab.rawValue)")
            print("   - Course classes count: \(course.classes?.count ?? 0)")
            print("   - Course has classes: \(course.hasClasses)")
        }
    }

    // MARK: - Tab Selector

    /// Tab selector UI with underline indicator
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(CourseDetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    print("🔄 [CourseDetailTabsView] Tab changed: \(selectedTab.rawValue) -> \(tab.rawValue)")
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(.bodyEmphasized)
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            .padding(.vertical, Spacing.spacing3)
                            .padding(.horizontal, Spacing.spacing4)

                        // Underline indicator
                        Rectangle()
                            .fill(selectedTab == tab ? Color.primaryBlue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .accessibilityLabel("Tab \(tab.rawValue)")
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .background(Color.cardBackground)
    }

    // MARK: - Tab Content

    /// Content view based on selected tab
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .syllabus:
            let classes = course.classes ?? []
            let _ = print("📚 [CourseDetailTabsView] Rendering Syllabus tab with \(classes.count) classes")
            SyllabusListView(classes: classes, courseThumbnail: course.thumbnail)
        case .about:
            let _ = print("ℹ️ [CourseDetailTabsView] Rendering About tab")
            CourseAboutView(course: course)
        }
    }
}

// MARK: - Preview
#Preview {
    CourseDetailTabsView(
        selectedTab: .constant(.syllabus),
        course: Course.mockCourses[0]
    )
}

