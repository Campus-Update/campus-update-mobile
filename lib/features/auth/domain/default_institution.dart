import 'institution.dart';

/// Default mock institution data matching Lead City University.
///
/// Used as a fallback when offline or before the school tree has been
/// fetched from the network, providing the exact structure shown in
/// the design specifications.
final defaultLeadCityUniversity = Institution(
  id: 'lead-city-university',
  name: 'Lead City University',
  slug: 'lead-city-university',
  faculties: [
    Faculty(
      id: 'focit',
      name: 'Faculty of Computting Information Technology (FOCIT)',
      code: 'FOCIT',
      departments: [
        Department(
          id: 'software-engineering',
          name: 'Software Engineering',
          code: 'SE',
          programmes: [
            Programme(
              id: 'software-engineering-prog',
              name: 'Software Engineering',
              code: 'SE',
              levels: [
                AcademicLevel(id: 'lvl-100', name: '100 Level', sortOrder: 100),
                AcademicLevel(id: 'lvl-200', name: '200 Level', sortOrder: 200),
                AcademicLevel(id: 'lvl-300', name: '300 Level', sortOrder: 300),
                AcademicLevel(id: 'lvl-400', name: '400 Level', sortOrder: 400),
                AcademicLevel(
                  id: 'lvl-se',
                  name: 'Software Engineering',
                  sortOrder: 500,
                ),
              ],
            ),
            Programme(
              id: 'computer-science-prog',
              name: 'Computer Science',
              code: 'CS',
              levels: [
                AcademicLevel(id: 'lvl-cs-100', name: '100 Level', sortOrder: 100),
                AcademicLevel(id: 'lvl-cs-200', name: '200 Level', sortOrder: 200),
                AcademicLevel(id: 'lvl-cs-300', name: '300 Level', sortOrder: 300),
                AcademicLevel(id: 'lvl-cs-400', name: '400 Level', sortOrder: 400),
              ],
            ),
          ],
        ),
        Department(
          id: 'computer-science',
          name: 'Computer Science',
          code: 'CS',
          programmes: [
            Programme(
              id: 'cs-bsc',
              name: 'B.Sc Computer Science',
              code: 'CS',
              levels: [
                AcademicLevel(id: 'lvl-100', name: '100 Level', sortOrder: 100),
                AcademicLevel(id: 'lvl-200', name: '200 Level', sortOrder: 200),
                AcademicLevel(id: 'lvl-300', name: '300 Level', sortOrder: 300),
                AcademicLevel(id: 'lvl-400', name: '400 Level', sortOrder: 400),
              ],
            ),
          ],
        ),
      ],
    ),
    Faculty(
      id: 'fbms',
      name: 'Faculty of Basic Medical Sciences',
      code: 'FBMS',
      departments: [
        Department(
          id: 'nursing',
          name: 'Nursing Science',
          code: 'NS',
          programmes: [],
        ),
      ],
    ),
  ],
);
