//
//  AcademicReportsView.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import SwiftUI
import Combine

struct AcademicReportsView: View {
    @StateObject private var viewModel = AcademicReportsViewModel()
    
    let backgroundColor = Color(red: 0.94, green: 0.95, blue: 0.97)
    let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.14, green: 0.36, blue: 0.58), Color(red: 0.04, green: 0.11, blue: 0.18)]),
        startPoint: .top, endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack {
                // Custom Tab Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ReportTab.allCases, id: \.self) { tab in
                            Button(action: {
                                viewModel.selectedTab = tab
                            }) {
                                Text(tab.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(viewModel.selectedTab == tab ? .bold : .medium)
                                    .foregroundColor(viewModel.selectedTab == tab ? .white : .black)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(
                                        viewModel.selectedTab == tab
                                        ? cardGradient
                                        : LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
                                    )
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                
                // Content Area
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text(errorMessage).foregroundColor(.red)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            switch viewModel.selectedTab {
                            case .offered:
                                offeredCoursesList
                            case .dropped:
                                droppedCoursesList
                            case .transcript:
                                transcriptList
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationTitle("Academic Reports")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDataForActiveTab()
        }
    }
    
    // MARK: - Tab 1: Offered Courses View
    private var offeredCoursesList: some View {
        ForEach(viewModel.offeredCourses) { course in
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(course.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    // Showing actual API data
                    Text("\(course.courseId) • \(course.teacherName)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Tab 2: Dropped Courses View
    private var droppedCoursesList: some View {
        ForEach(viewModel.droppedCourses) { course in
            HStack(spacing: 0) {
                // The Orange Accent Bar
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 6)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(course.courseId)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text(course.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(course.session)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding()
                Spacer()
            }
            .background(cardGradient)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Tab 3: Transcript View
    // Using @State for expanding/collapsing local state
    private var transcriptList: some View {
        // Sort sessions so most recent is at the top (e.g., Fall 2023 above Spring 2023)
        ForEach(viewModel.transcriptData.keys.sorted(by: >), id: \.self) { session in
            TranscriptSessionCard(
                session: session,
                courses: viewModel.transcriptData[session] ?? [],
                gpa: viewModel.calculateGPA(for: viewModel.transcriptData[session] ?? [])
            )
        }
    }
}

// MARK: - Expandable Transcript Card Component
struct TranscriptSessionCard: View {
    let session: String
    let courses: [TranscriptCourse]
    let gpa: String
    @State private var isExpanded = false
    
    let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.14, green: 0.36, blue: 0.58), Color(red: 0.04, green: 0.11, blue: 0.18)]),
        startPoint: .top, endPoint: .bottom
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Always Visible)
            Button(action: {
                withAnimation { isExpanded.toggle() }
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(session)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("GPA: \(gpa)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            
            // Expandable Content
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(courses) { course in
                        Divider().background(Color.white.opacity(0.3))
                            .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.courseId)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(course.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Text(course.grade)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
            }
        }
        .background(cardGradient)
        .cornerRadius(12)
    }
}
