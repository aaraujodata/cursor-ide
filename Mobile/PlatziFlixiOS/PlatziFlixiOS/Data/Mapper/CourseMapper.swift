//
//  CourseMapper.swift
//  PlatziFlixiOS
//
//  Created by Santiago Moreno on 11/06/25.
//

import Foundation

/// Mapper to convert DTOs to Domain Models
struct CourseMapper {

    /// Converts CourseDTO to Course domain model
    static func toDomain(_ dto: CourseDTO) -> Course {
        return Course(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            thumbnail: dto.thumbnail,
            slug: dto.slug,
            teacherIds: dto.teacherId ?? [],
            teachers: nil, // List endpoint doesn't include full teacher info
            createdAt: parseDate(dto.createdAt),
            updatedAt: parseDate(dto.updatedAt),
            deletedAt: parseDate(dto.deletedAt),
            averageRating: dto.averageRating,
            totalRatings: dto.totalRatings,
            classes: nil // List endpoint doesn't include classes
        )
    }

    /// Converts array of CourseDTOs to array of Course domain models
    static func toDomain(_ dtos: [CourseDTO]) -> [Course] {
        return dtos.map { toDomain($0) }
    }

    /// Converts CourseDetailDTO to Course domain model
    static func toDomain(_ dto: CourseDetailDTO) -> Course {
        // DEBUG: Log DTO data
        print("🔍 [CourseMapper] Mapping CourseDetailDTO:")
        print("   - Course ID: \(dto.id)")
        print("   - Course Name: \(dto.name)")
        print("   - Classes count: \(dto.classes?.count ?? 0)")

        // Map classes from ClassDTO array to Class domain models
        let classes: [Class]? = dto.classes.map { classDTOs in
            print("   - Mapping \(classDTOs.count) classes")
            let mappedClasses = ClassMapper.toDomainFromBasicDTO(classDTOs)
            print("   - Mapped classes: \(mappedClasses.map { $0.name })")
            return mappedClasses
        } ?? nil

        print("   - Final classes count: \(classes?.count ?? 0)")

        return Course(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            thumbnail: dto.thumbnail,
            slug: dto.slug,
            teacherIds: dto.teacherId ?? [],
            teachers: nil, // API returns only IDs, not full teacher objects
            createdAt: nil, // Detail DTO doesn't include dates
            updatedAt: nil,
            deletedAt: nil,
            averageRating: dto.averageRating,
            totalRatings: dto.totalRatings,
            classes: classes
        )
    }

    // MARK: - Private Helpers

    /// Parses ISO8601 date string to Date
    private static func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            return date
        }

        // Fallback to simple date format
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        return simpleDateFormatter.date(from: dateString)
    }
}
