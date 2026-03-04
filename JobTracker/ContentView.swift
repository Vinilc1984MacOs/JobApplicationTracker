import SwiftUI
import UniformTypeIdentifiers
import MapKit
import Charts
import AppKit

// MARK: - 1. Data Models
struct JobApplication: Identifiable, Codable, Equatable {
	var id = UUID()
	var index: Int
	var company: String
	var jobLink: String
	var role: String
	var status: String {
		didSet {
			if status.starts(with: "6") && processAge == nil {
				processAge = currentCalculatedAge
			} else if !status.starts(with: "6") {
				processAge = nil
			}
		}
	}
	var isInterviewPhase: Bool
	var linkedInURL: String
	var appliedDate: Date
	var culturalFit: Int
	var workModel: String
	var contractModel: String
	var pay: Double
	var location: String
	var latitude: Double?
	var longitude: Double?
	var processAge: Int?
	var observations: String
	
	var currentCalculatedAge: Int {
		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: Date())
		let startOfApplied = calendar.startOfDay(for: appliedDate)
		let components = calendar.dateComponents([.day], from: startOfApplied, to: startOfToday)
		return max(0, components.day ?? 0)
	}
	
	var displayAge: Int {
		return processAge ?? currentCalculatedAge
	}
	
	func calculatedRoleType(using rules: [RegexRule]) -> String {
		if role.isEmpty { return "" }
		let lowerRole = role.lowercased()
		for rule in rules where !rule.pattern.isEmpty {
			if lowerRole.contains(safeRegex: rule.pattern) {
				return rule.outputName
			}
		}
		return "6. Business & Management"
	}
	
	func calculatedSeniority(using rules: [RegexRule]) -> String {
		if role.isEmpty { return "" }
		let lowerRole = role.lowercased()
		for rule in rules where !rule.pattern.isEmpty {
			if lowerRole.contains(safeRegex: rule.pattern) {
				return rule.outputName
			}
		}
		return "4. Other/Entry"
	}
}

struct UserProfile: Codable, Equatable {
	var firstName = ""
	var lastName = ""
	var mobile = ""
	var email = ""
	var linkedIn = ""
	var profileImageData: Data? = nil
}

struct RegexRule: Identifiable, Codable, Equatable {
	var id = UUID()
	var pattern: String
	var outputName: String
	
	static let defaultRoleRules = [
		RegexRule(pattern: "sales|revenue|revops|commercial|pricing|ecommerce", outputName: "4. Sales & Revenue Ops"),
		RegexRule(pattern: "power bi|powerbi|fabric|bi |business intelligence", outputName: "1. BI & Visualization"),
		RegexRule(pattern: "data analyst|data analytics|data engineer", outputName: "3. Data Analytics"),
		RegexRule(pattern: "operations|ops", outputName: "5. General Operations"),
		RegexRule(pattern: "planner|planning|strategy|demand", outputName: "2. Strategy & Planning")
	]
	
	static let defaultSeniorityRules = [
		RegexRule(pattern: "head|global|regional|director", outputName: "1. Executive/Leadership"),
		RegexRule(pattern: "manager|lead|leader|coordenador|partner", outputName: "2a. Management"),
		RegexRule(pattern: "senior|sénior|iii|sr", outputName: "3. Senior"),
		RegexRule(pattern: "analyst|consultant|specialist|trader|developer|planner|controller|engineer", outputName: "2b. Specialist/Analyst")
	]
}

struct DropdownOption: Identifiable, Codable, Equatable {
	var id = UUID()
	var value: String
	var colorName: String?
	var isBold: Bool?
	var defaultLocation: String?
	var isRejected: Bool?
	
	var safeColorName: String { return colorName ?? "Primary" }
	var safeIsBold: Bool { return isBold ?? false }
	var safeDefaultLocation: String { return defaultLocation ?? "" }
	var safeIsRejected: Bool { return isRejected ?? false }
	
	var uiColor: Color {
		switch safeColorName {
		case "Blue": return .blue
		case "Cyan": return .cyan
		case "Indigo": return .indigo
		case "Green": return .green
		case "Red": return .red
		case "Pink": return .pink
		case "Yellow": return .yellow
		case "Orange": return .orange
		case "Purple": return .purple
		case "Mint": return .mint
		case "Gray": return .gray
		default: return .primary
		}
	}
	
	static let availableColors = ["Primary", "Blue", "Cyan", "Indigo", "Green", "Red", "Pink", "Yellow", "Orange", "Purple", "Mint", "Gray"]
	
	static let defaultStatuses = [
		DropdownOption(value: "1. Applied", colorName: "Primary", isBold: false),
		DropdownOption(value: "2. Initital Contact Made", colorName: "Cyan", isBold: false),
		DropdownOption(value: "3. Initial Interview Set", colorName: "Cyan", isBold: false),
		DropdownOption(value: "4. In Progress", colorName: "Blue", isBold: false),
		DropdownOption(value: "5. Final Stages", colorName: "Indigo", isBold: true),
		DropdownOption(value: "6. Job Offer", colorName: "Green", isBold: true),
		DropdownOption(value: "6. Not going Further", colorName: "Red", isBold: true, isRejected: true),
		DropdownOption(value: "6. Job Vacancy On-hold", colorName: "Gray", isBold: true)
	]
	
	static let defaultWorkModels = [
		DropdownOption(value: "Remote", colorName: "Blue", defaultLocation: "Valongo, PT"),
		DropdownOption(value: "Hybrid", colorName: "Cyan"),
		DropdownOption(value: "On-Site", colorName: "Gray")
	]
	
	static let defaultContractModels = [
		DropdownOption(value: "1. Full-Time | Long-Term", colorName: "Blue", isBold: true),
		DropdownOption(value: "2. Full-Time | Contract", colorName: "Cyan"),
		DropdownOption(value: "3. Part-Time | Contract", colorName: "Gray"),
		DropdownOption(value: "4. Temporary | Cover", colorName: "Gray")
	]
	
	static let defaultDocClassifications = [
		DropdownOption(value: "General", colorName: "Primary"),
		DropdownOption(value: "CV / Resume", colorName: "Blue", isBold: true),
		DropdownOption(value: "Cover Letter", colorName: "Cyan"),
		DropdownOption(value: "Portfolio", colorName: "Indigo"),
		DropdownOption(value: "Certificate", colorName: "Gray")
	]
}

struct StoredDocument: Identifiable, Codable, Equatable {
	var id = UUID()
	var name: String
	var fileURL: URL
	var dateAdded: Date
	var classification: String?
	var linkedApplicationID: UUID?
}

struct CalendarEvent: Identifiable {
	let id = UUID()
	let title: String
	let startDate: Date
	let endDate: Date
	let location: String
	let description: String
}

struct SaveDataWrapper: Codable {
	var applications: [JobApplication]
	var documents: [StoredDocument]
	var roleRules: [RegexRule]?
	var seniorityRules: [RegexRule]?
	var userProfile: UserProfile?
	var statusOptions: [DropdownOption]?
	var workModelOptions: [DropdownOption]?
	var contractModelOptions: [DropdownOption]?
	var docClassifications: [DropdownOption]?
	var defaultRemoteLocation: String?
	var defaultRemoteDisplayLabel: String?
}

// MARK: - Global Extensions & Helpers
extension String {
	func contains(safeRegex pattern: String) -> Bool {
		guard let _ = try? NSRegularExpression(pattern: pattern) else { return false }
		return self.range(of: pattern, options: .regularExpression) != nil
	}
}

extension Binding {
	func toUnwrapped<T>(default defaultValue: T) -> Binding<T> where Value == Optional<T> {
		Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
	}
}

extension Array where Element: Hashable {
	func unique() -> [Element] {
		var seen = Set<Element>()
		return filter { seen.insert($0).inserted }
	}
}

func formatCompactCurrency(_ value: Double) -> String {
	if value == 0 { return "-" }
	if value >= 1_000_000 { return String(format: "€%.1fM", value / 1_000_000) }
	if value >= 1_000 { return String(format: "€%.1fk", value / 1_000) }
	return String(format: "€%.0f", value)
}

func safeURL(from string: String) -> URL? {
	let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
	guard !trimmed.isEmpty else { return nil }
	if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
		return URL(string: trimmed)
	}
	return URL(string: "https://" + trimmed)
}

// MARK: - 2. Main Layout
struct ContentView: View {
	@State private var selection: Tab? = .applications
	
	@State private var applications: [JobApplication] = []
	@State private var documents: [StoredDocument] = []
	
	@State private var roleRules: [RegexRule] = RegexRule.defaultRoleRules
	@State private var seniorityRules: [RegexRule] = RegexRule.defaultSeniorityRules
	
	@State private var statusOptions: [DropdownOption] = DropdownOption.defaultStatuses
	@State private var workModelOptions: [DropdownOption] = DropdownOption.defaultWorkModels
	@State private var contractModelOptions: [DropdownOption] = DropdownOption.defaultContractModels
	@State private var docClassifications: [DropdownOption] = DropdownOption.defaultDocClassifications
	
	@State private var defaultRemoteLocation: String = "Valongo, PT"
	@State private var defaultRemoteDisplayLabel: String = "Remote"
	
	@AppStorage("jobTrackerCalendarURL") private var calendarURL: String = ""
	
	@State private var userProfile = UserProfile()
	@State private var showingRegistration = false
	
	enum Tab {
		case applications, dashboard, calendar, documents, profile, settings
	}
	
	var body: some View {
		NavigationSplitView {
			sidebarContent
		} detail: {
			mainContent
		}
		.tint(.blue)
		.sheet(isPresented: $showingRegistration) {
			RegistrationSheet(profile: $userProfile, isPresented: $showingRegistration)
		}
		.onAppear(perform: setupApp)
		.background(saveObserver)
	}
	
	private var sidebarContent: some View {
		VStack(spacing: 0) {
			List(selection: $selection) {
				NavigationLink(value: Tab.applications) {
					Label(title: { Text("Applications").foregroundColor(.primary) },
						  icon: { Image(systemName: "list.bullet.rectangle.portrait.fill").foregroundColor(.blue) })
				}
				NavigationLink(value: Tab.dashboard) {
					Label(title: { Text("Dashboard").foregroundColor(.primary) },
						  icon: { Image(systemName: "chart.pie.fill").foregroundColor(.cyan) })
				}
				NavigationLink(value: Tab.calendar) {
					Label(title: { Text("Interviews").foregroundColor(.primary) },
						  icon: { Image(systemName: "calendar").foregroundColor(.indigo) })
				}
				NavigationLink(value: Tab.documents) {
					Label(title: { Text("Documents").foregroundColor(.primary) },
						  icon: { Image(systemName: "folder.fill").foregroundColor(.gray) })
				}
			}
			List(selection: $selection) {
				NavigationLink(value: Tab.profile) {
					Label(title: { Text("My Profile").foregroundColor(.primary) },
						  icon: { Image(systemName: "person.crop.circle").foregroundColor(.gray) })
				}
				NavigationLink(value: Tab.settings) {
					Label(title: { Text("Settings").foregroundColor(.primary) },
						  icon: { Image(systemName: "gearshape.fill").foregroundColor(.gray) })
				}
			}
			.frame(height: 90)
			.scrollDisabled(true)
		}
		.padding(.top, 20) // Aligns perfectly with the 20pt padding of the main view card!
		.navigationTitle("Job Application Tracker")
	}
	
	private var pageTitle: String {
		switch selection {
		case .applications: return "Applications"
		case .dashboard: return "Dashboard"
		case .calendar: return "Interview Schedule"
		case .documents: return "Documents"
		case .profile: return "My Profile"
		case .settings: return "Settings"
		case .none: return ""
		}
	}
	
	private var mainContent: some View {
		ZStack {
			// Beautiful glass background gradient
			LinearGradient(colors: [Color.blue.opacity(0.1), Color.gray.opacity(0.2)],
						   startPoint: .topLeading, endPoint: .bottomTrailing)
				.ignoresSafeArea()
			
			VStack(spacing: 0) {
				// UNIVERSAL CUSTOM HEADER
				HStack {
					Text(pageTitle)
						.font(.title)
						.fontWeight(.bold)
						.foregroundColor(.primary)
					
					Spacer()
					
					if !userProfile.firstName.trimmingCharacters(in: .whitespaces).isEmpty {
						HStack(spacing: 12) {
							VStack(alignment: .trailing, spacing: 0) {
								Text("Welcome,")
									.font(.system(size: 11))
									.foregroundColor(.secondary)
								Text("\(userProfile.firstName) \(userProfile.lastName)")
									.font(.system(size: 13, weight: .semibold))
									.foregroundColor(.primary)
							}
							
							if let data = userProfile.profileImageData, let nsImage = NSImage(data: data) {
								Image(nsImage: nsImage)
									.resizable()
									.scaledToFill()
									.frame(width: 32, height: 32)
									.clipShape(Circle())
									.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
							} else {
								ZStack {
									Circle()
										.fill(Color.blue.opacity(0.1))
										.frame(width: 32, height: 32)
									Image(systemName: "person.fill")
										.foregroundColor(.blue)
										.font(.system(size: 14))
								}
							}
						}
						.padding(.leading, 16)
						.padding(.trailing, 6)
						.padding(.vertical, 6)
						.background(Color.primary.opacity(0.04))
						.clipShape(Capsule())
						.overlay(Capsule().stroke(Color.gray.opacity(0.15), lineWidth: 1))
					}
				}
				.padding(.horizontal, 25)
				.padding(.top, 20)
				.padding(.bottom, 15)
				
				Divider()
				
				// DETAIL VIEWS
				VStack {
					switch selection {
					case .applications:
						ApplicationListView(applications: $applications, roleRules: roleRules, seniorityRules: seniorityRules, statusOptions: statusOptions, workModelOptions: workModelOptions, contractModelOptions: contractModelOptions, defaultRemoteLocation: defaultRemoteLocation, defaultRemoteDisplayLabel: defaultRemoteDisplayLabel)
					case .dashboard:
						DashboardView(applications: applications, roleRules: roleRules, seniorityRules: seniorityRules, statusOptions: statusOptions, workModelOptions: workModelOptions, defaultRemoteDisplayLabel: defaultRemoteDisplayLabel)
					case .calendar:
						CalendarView(calendarURL: $calendarURL)
					case .documents:
						DocumentsView(documents: $documents, docClassifications: docClassifications, applications: applications)
					case .profile:
						ProfileView(profile: $userProfile, calendarURL: $calendarURL)
					case .settings:
						SettingsView(roleRules: $roleRules, seniorityRules: $seniorityRules, statusOptions: $statusOptions, workModelOptions: $workModelOptions, contractModelOptions: $contractModelOptions, docClassifications: $docClassifications, defaultRemoteLocation: $defaultRemoteLocation, defaultRemoteDisplayLabel: $defaultRemoteDisplayLabel)
					case .none:
						Text("Select an option")
							.foregroundColor(.secondary)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(.ultraThinMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.3), lineWidth: 1))
			.shadow(color: .black.opacity(0.12), radius: 15, x: 0, y: 8)
			.padding(20)
		}
	}
	
	private var saveObserver: some View {
		Group {
			Color.clear.onChange(of: applications) { saveData() }
			Color.clear.onChange(of: documents) { saveData() }
			Color.clear.onChange(of: roleRules) { saveData() }
			Color.clear.onChange(of: seniorityRules) { saveData() }
			Color.clear.onChange(of: userProfile) { saveData() }
			Color.clear.onChange(of: statusOptions) { saveData() }
			Color.clear.onChange(of: workModelOptions) { saveData() }
			Color.clear.onChange(of: contractModelOptions) { saveData() }
			Color.clear.onChange(of: docClassifications) { saveData() }
			Color.clear.onChange(of: defaultRemoteLocation) { saveData() }
			Color.clear.onChange(of: defaultRemoteDisplayLabel) { saveData() }
		}
	}
	
	private func setupApp() {
		loadData()
		if userProfile.firstName.trimmingCharacters(in: .whitespaces).isEmpty {
			showingRegistration = true
		}
	}
	
	private func getSaveURL() -> URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("JobTrackerData.json")
	}
	
	private func saveData() {
		if let encoded = try? JSONEncoder().encode(SaveDataWrapper(
			applications: applications, documents: documents, roleRules: roleRules, seniorityRules: seniorityRules, userProfile: userProfile, statusOptions: statusOptions, workModelOptions: workModelOptions, contractModelOptions: contractModelOptions, docClassifications: docClassifications, defaultRemoteLocation: defaultRemoteLocation, defaultRemoteDisplayLabel: defaultRemoteDisplayLabel
		)) {
			try? encoded.write(to: getSaveURL())
		}
	}
	
	private func loadData() {
		if let data = try? Data(contentsOf: getSaveURL()), let decoded = try? JSONDecoder().decode(SaveDataWrapper.self, from: data) {
			applications = decoded.applications
			documents = decoded.documents
			if let r = decoded.roleRules { roleRules = r }
			if let s = decoded.seniorityRules { seniorityRules = s }
			if let p = decoded.userProfile { userProfile = p }
			if let stat = decoded.statusOptions { statusOptions = stat }
			if let wm = decoded.workModelOptions { workModelOptions = wm }
			if let cm = decoded.contractModelOptions { contractModelOptions = cm }
			if let dc = decoded.docClassifications { docClassifications = dc }
			if let drl = decoded.defaultRemoteLocation { defaultRemoteLocation = drl }
			if let drdl = decoded.defaultRemoteDisplayLabel { defaultRemoteDisplayLabel = drdl }
		}
	}
}

// MARK: - Modern UI Components

struct MultiSelectMenu: View {
	var title: String
	var options: [String]
	@Binding var selection: Set<String>
	
	var body: some View {
		Menu {
			ForEach(options, id: \.self) { option in
				Button(action: {
					if selection.contains(option) {
						selection.remove(option)
					} else {
						selection.insert(option)
					}
				}) {
					HStack {
						Text(option)
						if selection.contains(option) {
							Image(systemName: "checkmark")
						}
					}
				}
			}
		} label: {
			Text(selection.isEmpty ? "All \(title)" : "\(title) (\(selection.count))")
		}
		.frame(width: 140)
	}
}

struct ModernTextField: View {
	var label: String
	var placeholder: String
	@Binding var text: String
	var icon: String? = nil
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(label)
				.font(.caption)
				.fontWeight(.medium)
				.foregroundColor(.secondary)
				.textCase(.uppercase)
			
			HStack(spacing: 12) {
				if let icon = icon {
					Image(systemName: icon).foregroundColor(.blue.opacity(0.8)).frame(width: 20)
				}
				TextField(placeholder, text: $text).textFieldStyle(.plain).font(.body)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.background(Color.primary.opacity(0.05))
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
		}
	}
}

struct ProfileSectionCard<Content: View>: View {
	var title: String
	var icon: String
	@ViewBuilder var content: () -> Content
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			Label(title, systemImage: icon)
				.font(.title3)
				.fontWeight(.semibold)
				.foregroundColor(.blue)
				.padding(.bottom, 5)
			content()
		}
		.padding(25)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

struct KPICard: View {
	var title: String
	var value: String
	var subtitle: String? = nil
	var icon: String
	var color: Color
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(title).font(.caption).fontWeight(.medium).foregroundColor(.secondary).lineLimit(1)
				Spacer()
				Image(systemName: icon).foregroundColor(color).font(.headline)
			}
			HStack(alignment: .firstTextBaseline, spacing: 6) {
				Text(value).font(.system(size: 22, weight: .semibold, design: .rounded))
				if let sub = subtitle {
					Text(sub).font(.caption).foregroundColor(.secondary)
				}
			}
		}
		.padding(15)
		.frame(width: 160, alignment: .leading) // Fixed width for horizontal scrolling
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

struct TrendKPICard: View {
	var title: String
	var value: String
	var trendPercentage: Double
	var icon: String
	
	var isPositive: Bool { trendPercentage >= 0 }
	var isZero: Bool { trendPercentage == 0 && value == "0" }
	
	var trendColor: Color {
		if isZero { return .secondary }
		return isPositive ? .green : .red
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(title).font(.caption).fontWeight(.medium).foregroundColor(.secondary).lineLimit(1)
				Spacer()
				Image(systemName: icon).foregroundColor(trendColor).font(.headline)
			}
			HStack(alignment: .firstTextBaseline) {
				Text(value)
					.font(.system(size: 26, weight: .semibold, design: .rounded))
					.foregroundColor(trendColor)
				
				Spacer()
				
				HStack(spacing: 2) {
					Image(systemName: isZero ? "minus" : (isPositive ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"))
						.font(.system(size: 14, weight: .black))
					Text("\(isPositive && !isZero ? "+" : "")\(Int(trendPercentage))%")
						.font(.system(size: 18, weight: .bold, design: .rounded))
				}
				.foregroundColor(trendColor)
			}
		}
		.padding(15)
		.frame(width: 170, alignment: .leading)
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

struct ChartCard<Content: View>: View {
	var title: String
	@ViewBuilder var content: () -> Content
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(title).font(.headline).foregroundColor(.secondary).padding(.bottom, 5)
			content().frame(minHeight: 200, maxHeight: .infinity)
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

struct StarRating: View {
	@Binding var rating: Int
	
	var body: some View {
		HStack(spacing: 2) {
			ForEach(1...5, id: \.self) { index in
				Image(systemName: index <= rating ? "star.fill" : "star")
					.foregroundColor(index <= rating ? .yellow : .gray.opacity(0.4))
					.shadow(color: index <= rating ? .yellow.opacity(0.4) : .clear, radius: index <= rating ? 4 : 0)
					.scaleEffect(index <= rating ? 1.15 : 1.0)
					.onTapGesture { rating = index }
			}
		}
		.animation(.spring(response: 0.3, dampingFraction: 0.5), value: rating)
	}
}

// MARK: - 3. Dashboard View
struct SalaryGroupData: Identifiable {
	var id: String { "\(role)-\(seniority)" }
	let role: String
	let seniority: String
	let avg: Double
}

struct MapBubbleData: Identifiable {
	var id: String { locationName }
	let locationName: String
	let coordinate: CLLocationCoordinate2D
	let count: Int
	let avgSalary: Double
}

struct SummaryRowData: Identifiable {
	var id: String { name }
	let name: String
	let count: Int
	let avgSalary: Double
	let avgAge: Double
}

enum BubbleMetric {
	case count, salary
}

struct DashboardView: View {
	var applications: [JobApplication]
	var roleRules: [RegexRule]
	var seniorityRules: [RegexRule]
	var statusOptions: [DropdownOption]
	var workModelOptions: [DropdownOption]
	var defaultRemoteDisplayLabel: String
	
	@State private var filterStatus = Set<String>()
	@State private var filterWorkModel = Set<String>()
	@State private var filterSeniority = Set<String>()
	@State private var filterLocation = Set<String>()
	
	var filteredApps: [JobApplication] {
		applications.filter { app in
			let appDisplayLoc = app.workModel.lowercased().contains("remote") ? defaultRemoteDisplayLabel : app.location
			let matchesStatus = filterStatus.isEmpty || filterStatus.contains(app.status)
			let matchesWorkModel = filterWorkModel.isEmpty || filterWorkModel.contains(app.workModel)
			let matchesSeniority = filterSeniority.isEmpty || filterSeniority.contains(app.calculatedSeniority(using: seniorityRules))
			let matchesLocation = filterLocation.isEmpty || filterLocation.contains(appDisplayLoc)
			
			return matchesStatus && matchesWorkModel && matchesSeniority && matchesLocation
		}
	}
	
	var todaysAppsCount: Int {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		return applications.filter { calendar.startOfDay(for: $0.appliedDate) == today }.count
	}
	
	var velocityPerBusinessDay: Double {
		guard !applications.isEmpty else { return 0 }
		let calendar = Calendar.current
		let firstAppDate = applications.map(\.appliedDate).min() ?? Date()
		let start = calendar.startOfDay(for: firstAppDate)
		let end = calendar.startOfDay(for: Date())
		
		var businessDays = 0
		var curr = start
		while curr <= end {
			if !calendar.isDateInWeekend(curr) {
				businessDays += 1
			}
			curr = calendar.date(byAdding: .day, value: 1, to: curr)!
		}
		
		let days = max(1, businessDays)
		return Double(applications.count) / Double(days)
	}
	
	var todaysTrendPercentage: Double {
		let avg = velocityPerBusinessDay
		let today = Double(todaysAppsCount)
		if avg == 0 { return today > 0 ? 100.0 : 0.0 }
		return ((today - avg) / avg) * 100.0
	}
	
	var activeApps: Int {
		filteredApps.filter { !$0.status.starts(with: "6. Not") && !$0.status.starts(with: "6. Job Vac") }.count
	}
	
	var offers: Int {
		filteredApps.filter { $0.status == "6. Job Offer" }.count
	}
	
	var avgPay: Double {
		let valid = filteredApps.map { $0.pay }.filter { $0 > 0 }
		return valid.isEmpty ? 0 : valid.reduce(0, +) / Double(valid.count)
	}
	
	var avgAgeOverall: Double {
		let ages = filteredApps.map { Double($0.displayAge) }
		return ages.isEmpty ? 0 : ages.reduce(0, +) / Double(ages.count)
	}
	
	var successRate: Double {
		let interviewsCount = filteredApps.filter { $0.isInterviewPhase }.count
		return filteredApps.isEmpty ? 0.0 : (Double(interviewsCount) / Double(filteredApps.count)) * 100.0
	}
	
	var pipelineData: [(status: String, count: Int, color: Color)] {
		var counts: [String: Int] = [:]
		for app in filteredApps {
			counts[app.status, default: 0] += 1
		}
		return counts.map { (status, count) in
			let matchedOption = statusOptions.first(where: { $0.value == status })
			let color = matchedOption?.uiColor ?? .primary
			return (status, count, color)
		}.sorted { $0.status < $1.status }
	}
	
	var ageByStatusData: [(status: String, avgAge: Double)] {
		Dictionary(grouping: filteredApps, by: { $0.status }).map { (key, apps) in
			let ages = apps.map { Double($0.displayAge) }
			let avg = ages.isEmpty ? 0 : ages.reduce(0, +) / Double(ages.count)
			return (status: key, avgAge: avg)
		}.sorted { $0.status < $1.status }
	}
	
	var timelineData: [(month: Date, count: Int)] {
		let calendar = Calendar.current
		return Dictionary(grouping: filteredApps, by: { calendar.date(from: calendar.dateComponents([.year, .month], from: $0.appliedDate)) ?? $0.appliedDate }).map { (key, apps) in
			return (month: key, count: apps.count)
		}.sorted { $0.month < $1.month }
	}
	
	var groupedSalaryData: [SalaryGroupData] {
		let grouped = Dictionary(grouping: filteredApps) { "\($0.calculatedRoleType(using: roleRules))|\($0.calculatedSeniority(using: seniorityRules))" }
		return grouped.compactMap { (key, apps) in
			let valid = apps.map { $0.pay }.filter { $0 > 0 }
			guard !valid.isEmpty else { return nil }
			let avg = valid.reduce(0, +) / Double(valid.count)
			let parts = key.components(separatedBy: "|")
			return SalaryGroupData(role: parts[0], seniority: parts[1], avg: avg)
		}.sorted { $0.role < $1.role }
	}
	
	var mapBubbles: [MapBubbleData] {
		let grouped = Dictionary(grouping: filteredApps.filter { $0.latitude != nil && $0.longitude != nil }, by: { $0.workModel.lowercased().contains("remote") ? defaultRemoteDisplayLabel : $0.location })
		return grouped.compactMap { (loc, apps) in
			guard let firstApp = apps.first(where: { $0.latitude != nil }), let lat = firstApp.latitude, let lon = firstApp.longitude else { return nil }
			let count = apps.count
			let validSalaries = apps.map { $0.pay }.filter { $0 > 0 }
			let avg = validSalaries.isEmpty ? 0 : validSalaries.reduce(0, +) / Double(validSalaries.count)
			return MapBubbleData(locationName: loc, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), count: count, avgSalary: avg)
		}
	}
	
	private func getSummaryData(by keyPath: (JobApplication) -> String) -> [SummaryRowData] {
		let grouped = Dictionary(grouping: filteredApps, by: keyPath)
		return grouped.map { key, apps in
			let validPay = apps.map(\.pay).filter { $0 > 0 }
			let avgPay = validPay.isEmpty ? 0 : validPay.reduce(0, +) / Double(validPay.count)
			let ages = apps.map { Double($0.displayAge) }
			let avgAge = ages.isEmpty ? 0 : ages.reduce(0, +) / Double(ages.count)
			return SummaryRowData(name: key.isEmpty ? "Unknown" : key, count: apps.count, avgSalary: avgPay, avgAge: avgAge)
		}.sorted { $0.count > $1.count }
	}

	let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
	let summaryGridLayout = [GridItem(.adaptive(minimum: 350), spacing: 20)]
	
	var body: some View {
		VStack(spacing: 0) {
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 15) {
					Image(systemName: "line.3.horizontal.decrease.circle.fill")
						.foregroundColor(.blue)
					Text("Dashboard Filters:").font(.headline)
					
					MultiSelectMenu(title: "Status", options: statusOptions.map(\.value), selection: $filterStatus)
					MultiSelectMenu(title: "Model", options: workModelOptions.map(\.value), selection: $filterWorkModel)
					
					let seniorityOpts = seniorityRules.map { $0.outputName }.unique().sorted()
					MultiSelectMenu(title: "Seniority", options: seniorityOpts, selection: $filterSeniority)
					
					let locOpts = applications.map {
						$0.workModel.lowercased().contains("remote") ? defaultRemoteDisplayLabel : $0.location
					}.filter { !$0.isEmpty }.unique().sorted()
					MultiSelectMenu(title: "Location", options: locOpts, selection: $filterLocation)
					
					if !filterStatus.isEmpty || !filterWorkModel.isEmpty || !filterSeniority.isEmpty || !filterLocation.isEmpty {
						Button("Clear All") {
							filterStatus.removeAll()
							filterWorkModel.removeAll()
							filterSeniority.removeAll()
							filterLocation.removeAll()
						}
						.buttonStyle(.bordered)
						.tint(.red)
						.controlSize(.small)
					}
				}
				.padding(15)
			}
			.background(.regularMaterial)
			.overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.15)), alignment: .bottom)
			
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					if applications.isEmpty {
						VStack(spacing: 20) {
							Image(systemName: "chart.bar.xaxis").font(.system(size: 60)).foregroundColor(.secondary.opacity(0.5))
							Text("No data yet! Add applications to see your metrics.").font(.title2).foregroundColor(.secondary)
						}.frame(maxWidth: .infinity, minHeight: 400).padding(.top, 50)
					} else {
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 15) {
								KPICard(title: "Apps Shown", value: "\(filteredApps.count)", icon: "doc.on.doc.fill", color: .blue)
								KPICard(title: "Success Rate", value: String(format: "%.1f%%", successRate), icon: "target", color: .purple)
								TrendKPICard(title: "Today's Apps", value: "\(todaysAppsCount)", trendPercentage: todaysTrendPercentage, icon: "flame.fill")
								KPICard(title: "Active Pipeline", value: "\(activeApps)", icon: "bolt.fill", color: .indigo)
								KPICard(title: "Job Offers", value: "\(offers)", icon: "star.fill", color: .green)
								KPICard(title: "Avg. Target", value: formatCompactCurrency(avgPay), icon: "eurosign.circle.fill", color: .gray)
								KPICard(title: "Avg. App Age", value: "\(Int(avgAgeOverall)) days", icon: "clock.fill", color: .gray)
							}
							.padding(.horizontal, 20)
							.padding(.top, 20)
							.padding(.bottom, 5)
						}
						
						LazyVGrid(columns: gridLayout, spacing: 20) {
							ChartCard(title: "Pipeline Status") {
								Chart(pipelineData, id: \.status) { data in
									BarMark(x: .value("Count", data.count), y: .value("Status", data.status))
										.foregroundStyle(data.color.gradient)
										.cornerRadius(4)
										.annotation(position: .trailing) { Text("\(data.count)").font(.caption).foregroundColor(.secondary) }
								}.chartXAxis(.hidden)
							}
							
							ChartCard(title: "Avg. Process Age by Status (Days)") {
								Chart(ageByStatusData, id: \.status) { data in
									let statusOpt = statusOptions.first(where: { $0.value == data.status })
									BarMark(x: .value("Avg Age", data.avgAge), y: .value("Status", data.status))
										.foregroundStyle((statusOpt?.uiColor ?? .gray).gradient)
										.cornerRadius(4)
										.annotation(position: .trailing) { Text("\(Int(data.avgAge))").font(.caption).foregroundColor(.secondary) }
								}.chartXAxis(.hidden)
							}
							
							ChartCard(title: "Application Momentum (Timeline)") {
								Chart(timelineData, id: \.month) { data in
									LineMark(x: .value("Month", data.month), y: .value("Apps", data.count))
										.symbol(Circle().strokeBorder(lineWidth: 2))
										.foregroundStyle(Color.blue.gradient)
									AreaMark(x: .value("Month", data.month), y: .value("Apps", data.count))
										.foregroundStyle(LinearGradient(colors: [.blue.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
								}
							}
							
							ChartCard(title: "Avg. Salary by Role & Seniority") {
								if groupedSalaryData.isEmpty {
									Text("Add Pay amounts to your applications to see this chart.").font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
								} else {
									Chart(groupedSalaryData, id: \.id) { data in
										BarMark(x: .value("Role", data.role), y: .value("Avg Salary", data.avg))
											.foregroundStyle(by: .value("Seniority", data.seniority))
											.position(by: .value("Seniority", data.seniority))
											.cornerRadius(4)
											.annotation(position: .top, alignment: .center) { Text(formatCompactCurrency(data.avg)).font(.system(size: 9)).foregroundColor(.secondary) }
									}.chartLegend(position: .bottom)
								}
							}
						}.padding(.horizontal, 20)
						
						DashboardBubbleMap(mapBubbles: mapBubbles).padding(.horizontal, 20)
						
						// Responsive adaptive grid for Summary Tables
						LazyVGrid(columns: summaryGridLayout, alignment: .leading, spacing: 20) {
							SummaryTableView(title: "Role Seniority", data: getSummaryData { $0.calculatedSeniority(using: seniorityRules) })
							SummaryTableView(title: "Type of Function", data: getSummaryData { $0.calculatedRoleType(using: roleRules) })
							SummaryTableView(title: "Application Status", data: getSummaryData { $0.status })
							SummaryTableView(title: "Location", data: getSummaryData { app in
								if app.workModel.lowercased().contains("remote") { return defaultRemoteDisplayLabel }
								return app.location
							})
							SummaryTableView(title: "Work Model", data: getSummaryData { $0.workModel })
						}.padding(.horizontal, 20).padding(.bottom, 40)
					}
				}
			}
		}
	}
}

struct DashboardBubbleMap: View {
	var mapBubbles: [MapBubbleData]
	@State private var selectedMapMetric: BubbleMetric = .count
	
	private func calculateBubbleSize(for bubble: MapBubbleData) -> CGFloat {
		let minSize: CGFloat = 35; let maxSize: CGFloat = 85
		if selectedMapMetric == .count {
			let maxCount = mapBubbles.map(\.count).max() ?? 1
			if maxCount == 0 { return minSize }
			return minSize + (CGFloat(bubble.count) / CGFloat(maxCount)) * (maxSize - minSize)
		} else {
			let maxSal = mapBubbles.map(\.avgSalary).max() ?? 1
			if maxSal == 0 { return minSize }
			return minSize + (CGFloat(bubble.avgSalary) / CGFloat(maxSal)) * (maxSize - minSize)
		}
	}
	
	private func bubbleText(for bubble: MapBubbleData) -> String {
		if selectedMapMetric == .count {
			return "\(bubble.count)"
		} else {
			if bubble.avgSalary == 0 { return "N/A" }
			return formatCompactCurrency(bubble.avgSalary)
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			HStack {
				Text("Geographic Distribution (Bubble Map)").font(.headline).foregroundColor(.secondary)
				Spacer()
				Picker("", selection: $selectedMapMetric) {
					Text("Application Count").tag(BubbleMetric.count)
					Text("Average Salary").tag(BubbleMetric.salary)
				}.pickerStyle(.segmented).frame(width: 250)
			}
			Map {
				ForEach(mapBubbles) { bubble in
					Annotation(bubble.locationName, coordinate: bubble.coordinate) {
						let size = calculateBubbleSize(for: bubble)
						Circle()
							.fill(Color.blue.opacity(0.4))
							.stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
							.frame(width: size, height: size)
							.overlay(Text(bubbleText(for: bubble)).font(.system(size: 11, weight: .bold)).foregroundColor(.primary))
					}
				}
			}
			.mapStyle(.standard(elevation: .flat))
			.frame(minHeight: 400, maxHeight: .infinity)
			.clipShape(RoundedRectangle(cornerRadius: 12))
		}
		.padding()
		.background(.regularMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

struct SummaryTableView: View {
	var title: String
	var data: [SummaryRowData]
	
	var totalQty: Int { data.map(\.count).reduce(0, +) }
	var totalAvgSalary: Double {
		let validRows = data.filter { $0.avgSalary > 0 }
		let totalValidCount = validRows.map(\.count).reduce(0, +)
		guard totalValidCount > 0 else { return 0 }
		return validRows.map { Double($0.count) * $0.avgSalary }.reduce(0, +) / Double(totalValidCount)
	}
	var totalAvgAge: Double {
		guard totalQty > 0 else { return 0 }
		return data.map { Double($0.count) * $0.avgAge }.reduce(0, +) / Double(totalQty)
	}
	
	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 10) {
				Text(title).font(.caption).bold().frame(maxWidth: .infinity, alignment: .leading)
				Text("Qty").font(.caption).bold().frame(width: 35, alignment: .trailing)
				Text("Avg. Salary").font(.caption).bold().frame(width: 75, alignment: .trailing)
				Text("Avg. Age").font(.caption).bold().frame(width: 55, alignment: .trailing)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 8)
			.background(Color.blue.opacity(0.05))
			
			ForEach(data) { row in
				HStack(spacing: 10) {
					Text(row.name).font(.caption).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading)
					Text("\(row.count)").font(.caption).frame(width: 35, alignment: .trailing)
					Text(formatCompactCurrency(row.avgSalary)).font(.caption).frame(width: 75, alignment: .trailing)
					Text("\(Int(row.avgAge))").font(.caption).frame(width: 55, alignment: .trailing)
				}
				.padding(.horizontal, 12)
				.padding(.vertical, 6)
				Divider()
			}
			
			if !data.isEmpty {
				HStack(spacing: 10) {
					Text("Total / Average").font(.caption).bold().frame(maxWidth: .infinity, alignment: .leading)
					Text("\(totalQty)").font(.caption).bold().frame(width: 35, alignment: .trailing)
					Text(formatCompactCurrency(totalAvgSalary)).font(.caption).bold().frame(width: 75, alignment: .trailing)
					Text("\(Int(totalAvgAge))").font(.caption).bold().frame(width: 55, alignment: .trailing)
				}
				.padding(.horizontal, 12)
				.padding(.vertical, 8)
				.background(Color.blue.opacity(0.05))
			}
		}
		.frame(maxHeight: .infinity, alignment: .top) // <--- FIX: Stretches card height to match the row and aligns content to the top!
		.frame(maxWidth: .infinity, alignment: .leading) // Line 1276 preservation logic
		.background(.regularMaterial)
		.cornerRadius(8)
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

// MARK: - 4. Calendar View (Custom URL Sync)
struct CalendarView: View {
	@Binding var calendarURL: String
	@State private var events: [CalendarEvent] = []
	@State private var isFetching = false
	@State private var selectedEvent: CalendarEvent?
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Text("Syncing directly via Google Calendar iCal URL").foregroundColor(.secondary)
				Spacer()
				Button(action: { Task { await fetchEvents() } }) {
					Label(isFetching ? "Syncing..." : "Refresh", systemImage: "arrow.clockwise")
				}.buttonStyle(.bordered).disabled(calendarURL.isEmpty || isFetching)
			}.padding([.horizontal, .top], 20).padding(.bottom, 10)
			
			if calendarURL.isEmpty {
				VStack(spacing: 20) {
					Image(systemName: "calendar.badge.plus").font(.system(size: 50)).foregroundColor(.blue)
					Text("Connect Google Calendar in My Profile").font(.title2).bold()
				}.frame(maxHeight: .infinity)
			} else {
				List(events) { event in
					Button(action: { selectedEvent = event }) {
						HStack(spacing: 15) {
							VStack(alignment: .center) {
								Text(event.startDate.formatted(.dateTime.day())).font(.title2).bold()
								Text(event.startDate.formatted(.dateTime.month(.abbreviated))).font(.caption).textCase(.uppercase)
							}
							.frame(width: 50)
							.padding(8)
							.background(Color.blue.opacity(0.1))
							.foregroundColor(.blue)
							.cornerRadius(10)
							
							VStack(alignment: .leading, spacing: 4) {
								Text(event.title).font(.headline)
								HStack {
									Label(event.startDate.formatted(date: .omitted, time: .shortened), systemImage: "clock")
									if !event.location.isEmpty {
										Label(event.location, systemImage: "mappin.and.ellipse").lineLimit(1)
									}
								}.font(.caption).foregroundColor(.secondary)
							}
							Spacer()
						}
						.padding(.vertical, 8)
						.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
				}.listStyle(.inset(alternatesRowBackgrounds: true))
			}
		}
		.onAppear { if !calendarURL.isEmpty { Task { await fetchEvents() } } }
		.sheet(item: $selectedEvent) { ev in EventDetailSheet(event: ev) }
	}
	
	private func fetchEvents() async {
		guard let url = URL(string: calendarURL.trimmingCharacters(in: .whitespaces)) else { return }
		isFetching = true
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			if let string = String(data: data, encoding: .utf8) {
				let parsed = parseICS(string)
				await MainActor.run {
					self.events = parsed.filter { event in
						let isUpcoming = event.startDate >= Date().addingTimeInterval(-86400)
						let t = event.title.lowercased()
						return isUpcoming && (t.contains("interview") || t.contains("meet") || t.contains("call") || t.contains("sync"))
					}.sorted { $0.startDate < $1.startDate }
					self.isFetching = false
				}
			}
		} catch {
			await MainActor.run { self.isFetching = false }
		}
	}
	
	private func parseICS(_ s: String) -> [CalendarEvent] {
		var res: [CalendarEvent] = []
		let lines = s.components(separatedBy: .newlines)
		var inEv = false
		var t = "", loc = "", desc = "", lastKey = ""
		var sd: Date?, ed: Date?
		
		for rawLine in lines {
			let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
			
			if rawLine.hasPrefix(" ") || rawLine.hasPrefix("\t") {
				if lastKey == "DESCRIPTION" { desc += line }
				else if lastKey == "LOCATION" { loc += line }
				else if lastKey == "SUMMARY" { t += line }
				continue
			}
			
			if line == "BEGIN:VEVENT" {
				inEv = true
				t = ""
				loc = ""
				desc = ""
				sd = nil
				ed = nil
				lastKey = ""
			} else if line == "END:VEVENT" {
				inEv = false
				if let d = sd {
					let cleanDesc = desc.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\,", with: ",")
					let cleanLoc = loc.replacingOccurrences(of: "\\,", with: ",")
					res.append(CalendarEvent(title: t, startDate: d, endDate: ed ?? d, location: cleanLoc, description: cleanDesc))
				}
			} else if inEv {
				if line.hasPrefix("SUMMARY:") {
					t = String(line.dropFirst(8))
					lastKey = "SUMMARY"
				} else if line.hasPrefix("LOCATION:") {
					loc = String(line.dropFirst(9))
					lastKey = "LOCATION"
				} else if line.hasPrefix("DESCRIPTION:") {
					desc = String(line.dropFirst(12))
					lastKey = "DESCRIPTION"
				} else if line.hasPrefix("DTSTART") {
					sd = parseICSDate(line)
					lastKey = "DTSTART"
				} else if line.hasPrefix("DTEND") {
					ed = parseICSDate(line)
					lastKey = "DTEND"
				} else {
					lastKey = ""
				}
			}
		}
		return res
	}
	
	private func parseICSDate(_ tr: String) -> Date? {
		let ds = tr.components(separatedBy: ":").last ?? ""
		let df = DateFormatter()
		df.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
		df.timeZone = TimeZone(abbreviation: "UTC")
		return df.date(from: ds)
	}
}

struct EventDetailSheet: View {
	var event: CalendarEvent
	@Environment(\.dismiss) var dismiss
	
	var meetingURLs: [URL] {
		let text = event.location + " " + event.description
		guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return [] }
		let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
		var urls = matches.compactMap { $0.url }
		urls = urls.filter { $0.scheme == "http" || $0.scheme == "https" }
		
		var uniqueURLs = [URL]()
		for url in urls { if !uniqueURLs.contains(url) { uniqueURLs.append(url) } }
		return uniqueURLs
	}
	
	func linkTitle(for url: URL) -> String {
		let str = url.absoluteString.lowercased()
		if str.contains("meet.google") { return "Join Google Meet" }
		if str.contains("zoom.us") || str.contains("zoom.gov") { return "Join Zoom Meeting" }
		if str.contains("teams.microsoft") || str.contains("teams.live") { return "Join Microsoft Teams" }
		if str.contains("webex") { return "Join Webex Meeting" }
		return "Open Link"
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			Text(event.title).font(.largeTitle).bold()
			
			VStack(alignment: .leading, spacing: 10) {
				Label(event.startDate.formatted(date: .complete, time: .shortened), systemImage: "clock.fill")
					.foregroundColor(.blue)
					.font(.headline)
				
				if !event.location.isEmpty {
					Label(event.location, systemImage: "mappin.circle.fill")
						.foregroundColor(.red)
				}
			}
			
			if !meetingURLs.isEmpty {
				VStack(alignment: .leading, spacing: 10) {
					Text("Meeting Links").font(.headline).foregroundColor(.secondary)
					ForEach(meetingURLs, id: \.self) { url in
						Link(destination: url) {
							Label(linkTitle(for: url), systemImage: "video.fill")
								.frame(maxWidth: .infinity)
						}
						.buttonStyle(.borderedProminent)
						.tint(.blue)
						.controlSize(.large)
					}
				}
				.padding(.vertical, 5)
			}
			
			if !event.description.isEmpty {
				Divider()
				Text("Details").font(.headline).foregroundColor(.secondary)
				ScrollView {
					Text(event.description)
						.font(.body)
						.textSelection(.enabled)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			Spacer()
			HStack {
				Spacer()
				Button("Close") {
					dismiss()
				}
				.buttonStyle(.borderedProminent)
				.tint(.gray)
				.keyboardShortcut(.defaultAction)
			}
		}
		.padding(30)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.ultraThinMaterial)
	}
}

// MARK: - 5. Profile & Registration Views
struct ProfileView: View {
	@Binding var profile: UserProfile
	@Binding var calendarURL: String
	
	var body: some View {
		ScrollView {
			VStack(spacing: 30) {
				VStack(spacing: 12) {
					Button(action: { selectProfileImage() }) {
						if let data = profile.profileImageData, let nsImage = NSImage(data: data) {
							Image(nsImage: nsImage).resizable().scaledToFill().frame(width: 110, height: 110).clipShape(Circle()).shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
						} else {
							Image(systemName: "person.crop.circle.fill").resizable().frame(width: 100, height: 100).foregroundColor(.blue)
						}
					}.buttonStyle(.plain)
				}
				.padding(.top, 30)
				
				VStack(spacing: 25) {
					ProfileSectionCard(title: "Account Sync", icon: "calendar.badge.plus") {
						VStack(alignment: .leading, spacing: 8) {
							Text("Google Calendar Secret iCal URL").font(.caption).fontWeight(.medium).foregroundColor(.secondary).textCase(.uppercase)
							
							HStack(spacing: 12) {
								Image(systemName: "link").foregroundColor(.blue.opacity(0.8)).frame(width: 20)
								SecureField("https://calendar.google.com/calendar/ical/...", text: $calendarURL)
									.textFieldStyle(.plain).font(.body)
							}
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
							.background(Color.primary.opacity(0.05))
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
							
							Text("Paste your private .ics link here to sync interviews automatically.").font(.caption2).foregroundColor(.secondary)
						}
					}
					
					ProfileSectionCard(title: "Personal Information", icon: "person.text.rectangle") {
						HStack(spacing: 20) {
							ModernTextField(label: "First Name", placeholder: "e.g. Jane", text: $profile.firstName, icon: "person")
							ModernTextField(label: "Last Name", placeholder: "e.g. Doe", text: $profile.lastName, icon: "person.fill")
						}
					}
					
					ProfileSectionCard(title: "Contact Details", icon: "envelope.fill") {
						HStack(spacing: 20) {
							ModernTextField(label: "Email Address", placeholder: "name@example.com", text: $profile.email, icon: "at")
							ModernTextField(label: "Mobile Number", placeholder: "+1 555 123 4567", text: $profile.mobile, icon: "phone.fill")
						}
					}
					
					ProfileSectionCard(title: "Professional", icon: "briefcase.fill") {
						HStack(alignment: .bottom, spacing: 12) {
							ModernTextField(label: "LinkedIn URL", placeholder: "linkedin.com/in/username", text: $profile.linkedIn, icon: "link")
							
							if let url = safeURL(from: profile.linkedIn) {
								Link(destination: url) {
									Image(systemName: "arrow.up.right.square.fill")
										.font(.system(size: 20))
										.foregroundColor(.blue)
										.padding(12)
										.background(Color.primary.opacity(0.05))
										.clipShape(RoundedRectangle(cornerRadius: 10))
										.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
								}
								.buttonStyle(.plain)
							}
						}
					}
				}
				.padding(.horizontal, 40)
				.padding(.bottom, 40)
			}
		}
	}
	
	private func selectProfileImage() {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.allowedContentTypes = [.image]
		if panel.runModal() == .OK {
			if let url = panel.url, let data = try? Data(contentsOf: url) {
				profile.profileImageData = data
			}
		}
	}
}

struct RegistrationSheet: View {
	@Binding var profile: UserProfile
	@Binding var isPresented: Bool
	
	var body: some View {
		VStack(spacing: 0) {
			VStack(spacing: 10) {
				Image(systemName: "sparkles").font(.system(size: 40)).foregroundColor(.blue)
				Text("Welcome to JobTracker!").font(.largeTitle).fontWeight(.bold)
				Text("Please set up your profile to get started.").foregroundColor(.secondary)
			}.padding(.top, 40).padding(.bottom, 30)
			
			ScrollView {
				VStack(spacing: 20) {
					ModernTextField(label: "First Name", placeholder: "e.g. Jane", text: $profile.firstName, icon: "person")
					ModernTextField(label: "Last Name", placeholder: "e.g. Doe", text: $profile.lastName, icon: "person.fill")
					ModernTextField(label: "Email Address", placeholder: "name@example.com", text: $profile.email, icon: "at")
					ModernTextField(label: "Mobile Number", placeholder: "+1 555 123 4567", text: $profile.mobile, icon: "phone.fill")
					ModernTextField(label: "LinkedIn Profile URL", placeholder: "linkedin.com/in/username", text: $profile.linkedIn, icon: "link")
				}.padding(.horizontal, 40)
			}
			
			Button(action: { isPresented = false }) {
				Text("Save & Continue").font(.headline).frame(maxWidth: .infinity).padding()
			}
			.buttonStyle(.borderedProminent)
			.tint(.blue)
			.controlSize(.large)
			.disabled(profile.firstName.trimmingCharacters(in: .whitespaces).isEmpty)
			.padding(40)
		}
		.frame(width: 500, height: 600)
		.background(.ultraThinMaterial)
	}
}

// MARK: - 6. Application List View
struct ApplicationListView: View {
	@Binding var applications: [JobApplication]
	var roleRules: [RegexRule]
	var seniorityRules: [RegexRule]
	var statusOptions: [DropdownOption]
	var workModelOptions: [DropdownOption]
	var contractModelOptions: [DropdownOption]
	var defaultRemoteLocation: String
	var defaultRemoteDisplayLabel: String
	
	@State private var filterCompany = ""
	@State private var filterRole = ""
	@State private var filterLocation = Set<String>()
	@State private var filterStatus = Set<String>()
	@State private var filterWorkModel = Set<String>()
	@State private var showActiveOnly = false
	
	@State private var sortOrder = [KeyPathComparator(\JobApplication.appliedDate, order: .forward)]
	@State private var showAdd = false
	@State private var showPaste = false
	@State private var editID: UUID?
	@State private var showingDeleteAllAlert = false
	
	@State private var newAppToSave = JobApplication(index: 0, company: "", jobLink: "", role: "", status: "", isInterviewPhase: false, linkedInURL: "", appliedDate: Date(), culturalFit: 0, workModel: "", contractModel: "", pay: 0.0, location: "", observations: "")
	
	var companyCounts: [String: Int] {
		var counts: [String: Int] = [:]
		for app in applications {
			let key = app.company.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
			if !key.isEmpty { counts[key, default: 0] += 1 }
		}
		return counts
	}
	
	private func getCompanyColor(company: String) -> Color? {
		let key = company.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		switch companyCounts[key] ?? 1 {
		case 2: return .indigo
		case 3: return .blue
		case 4...: return .cyan
		default: return nil
		}
	}
	
	var filteredAndSortedApps: [JobApplication] {
		var result = applications
		
		if showActiveOnly {
			result = result.filter { !$0.status.starts(with: "6. Not") && !$0.status.starts(with: "6. Job Vac") }
		}
		
		if !filterCompany.isEmpty { result = result.filter { $0.company.localizedCaseInsensitiveContains(filterCompany) } }
		if !filterRole.isEmpty { result = result.filter { $0.role.localizedCaseInsensitiveContains(filterRole) } }
		
		if !filterLocation.isEmpty {
			result = result.filter { app in
				let appDisplayLoc = app.workModel.lowercased().contains("remote") ? defaultRemoteDisplayLabel : app.location
				return filterLocation.contains(appDisplayLoc)
			}
		}
		
		if !filterStatus.isEmpty { result = result.filter { filterStatus.contains($0.status) } }
		if !filterWorkModel.isEmpty { result = result.filter { filterWorkModel.contains($0.workModel) } }
		
		result.sort(using: sortOrder)
		return result
	}
	
	private func getBinding(for appID: UUID) -> Binding<JobApplication> {
		Binding<JobApplication>(
			get: { applications.first(where: { $0.id == appID }) ?? applications[0] },
			set: { newValue in
				if let index = applications.firstIndex(where: { $0.id == appID }) {
					applications[index] = newValue
				}
			}
		)
	}
	
	var body: some View {
		VStack(spacing: 0) {
			topFilterBar
			Divider()
			
			Table(filteredAndSortedApps, selection: $editID, sortOrder: $sortOrder) {
				TableColumn("ID / Date", value: \.appliedDate) { app in
					idDateColumn(for: app)
				}
				
				TableColumn("Job Info", value: \.company) { app in
					jobInfoColumn(for: app)
				}
				
				TableColumn("Status", value: \.status) { app in
					statusColumn(for: app)
				}
				
				TableColumn("Cultural Fit", value: \.culturalFit) { app in
					culturalFitColumn(for: app)
				}
				
				TableColumn("Terms", value: \.workModel) { app in
					termsColumn(for: app)
				}
				
				TableColumn("Comp & Loc", value: \.pay) { app in
					compLocColumn(for: app)
				}
				
				TableColumn("Links", value: \.jobLink) { app in
					linksColumn(for: app)
				}
				
				TableColumn("Age / Obs.", value: \.displayAge) { app in
					ageObsColumn(for: app)
				}
			}
			.scrollContentBackground(.hidden)
			.background(Color.white.opacity(0.15))
			.onChange(of: sortOrder) { oldOrder, newOrder in
				if let oldFirst = oldOrder.first, let newFirst = newOrder.first, oldFirst.keyPath == newFirst.keyPath && oldFirst.order == .reverse && newFirst.order == .forward && newFirst.keyPath != \JobApplication.appliedDate {
					sortOrder = [KeyPathComparator(\JobApplication.appliedDate, order: .forward)]
				}
			}
			
			Divider()
			bottomToolbar
		}
		.sheet(isPresented: $showPaste) {
			PasteImportView(applications: $applications, isPresented: $showPaste, statusOptions: statusOptions, workModelOptions: workModelOptions, contractModelOptions: contractModelOptions, defaultRemoteLocation: defaultRemoteLocation)
		}
		.sheet(isPresented: $showAdd) {
			AddApplicationSheet(app: $newAppToSave, applications: $applications, isPresented: $showAdd, statusOptions: statusOptions, workModelOptions: workModelOptions, contractModelOptions: contractModelOptions, defaultRemoteLocation: defaultRemoteLocation)
		}
		.alert("Delete All Applications?", isPresented: $showingDeleteAllAlert) {
			Button("Cancel", role: .cancel) { }
			Button("Delete Everything", role: .destructive) { deleteAllApplications() }
		} message: {
			Text("This action cannot be undone. All application data will be permanently removed.")
		}
	}
	
	// MARK: - Extracted Table Columns
	@ViewBuilder private func idDateColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(alignment: .leading, spacing: 4) {
				Text("#\(app.index)").font(.caption).fontWeight(.semibold)
				DatePicker("", selection: bind.appliedDate, displayedComponents: .date).labelsHidden()
			}
		} else {
			VStack(alignment: .leading, spacing: 4) {
				Text("#\(app.index)").font(.caption).foregroundColor(.secondary)
				Text(app.appliedDate.formatted(.dateTime.day().month().year())).font(.subheadline).fontWeight(.medium)
			}
			.foregroundColor(statusOpt?.uiColor ?? .primary)
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func jobInfoColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(spacing: 4) {
				TextField("Company", text: bind.company).textFieldStyle(.roundedBorder)
				TextField("Role", text: bind.role).textFieldStyle(.roundedBorder)
			}
		} else {
			VStack(alignment: .leading, spacing: 4) {
				Text(app.company).font(.headline).foregroundColor(getCompanyColor(company: app.company) ?? .primary)
				Text(app.role).font(.subheadline).foregroundColor(.secondary)
			}
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func statusColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(alignment: .leading, spacing: 4) {
				Picker("", selection: bind.status) {
					ForEach(statusOptions) { opt in Text(opt.value).tag(opt.value) }
				}.labelsHidden()
				Toggle("Interviewing", isOn: bind.isInterviewPhase).toggleStyle(.checkbox).font(.caption)
			}
		} else {
			VStack(alignment: .leading, spacing: 4) {
				Text(app.status)
					.font(.caption)
					.fontWeight(.semibold)
					.foregroundColor(statusOpt?.uiColor ?? .primary)
					.padding(.horizontal, 8).padding(.vertical, 4)
					.background((statusOpt?.uiColor ?? .gray).opacity(0.15))
					.cornerRadius(6)
				if app.isInterviewPhase { Label("Interviewing", systemImage: "mic.fill").font(.caption2).foregroundColor(.blue) }
			}
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func culturalFitColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(alignment: .center, spacing: 4) { StarRating(rating: bind.culturalFit) }
		} else {
			VStack(alignment: .center, spacing: 4) {
				Text("\(app.culturalFit) / 5").font(.caption2).foregroundColor(.secondary)
				HStack(spacing: 2) {
					ForEach(1...5, id: \.self) { index in
						Image(systemName: index <= app.culturalFit ? "star.fill" : "star").foregroundColor(index <= app.culturalFit ? .yellow : .gray.opacity(0.3)).font(.caption2)
					}
				}
			}
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func termsColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let wmOpt = workModelOptions.first(where: { $0.value == bind.wrappedValue.workModel })
		let cmOpt = contractModelOptions.first(where: { $0.value == bind.wrappedValue.contractModel })
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		
		if editID == app.id {
			VStack(alignment: .leading, spacing: 4) {
				Picker("", selection: bind.workModel) {
					ForEach(workModelOptions) { opt in Text(opt.value).tag(opt.value) }
				}
				.labelsHidden()
				.onChange(of: bind.wrappedValue.workModel) { old, new in
					let matchedOpt = workModelOptions.first(where: { $0.value == new })
					if let defLoc = matchedOpt?.defaultLocation, !defLoc.isEmpty {
						bind.wrappedValue.location = defLoc
						geocodeLocation(for: bind.wrappedValue.id, locationName: defLoc)
					} else if new.lowercased().contains("remote") && !defaultRemoteLocation.isEmpty {
						bind.wrappedValue.location = defaultRemoteLocation
						geocodeLocation(for: bind.wrappedValue.id, locationName: defaultRemoteLocation)
					}
				}
				
				Picker("", selection: bind.contractModel) {
					ForEach(contractModelOptions) { opt in Text(opt.value).tag(opt.value) }
				}.labelsHidden()
			}
		} else {
			VStack(alignment: .leading, spacing: 4) {
				Text(app.workModel)
					.font(.caption)
					.fontWeight(.medium)
					.foregroundColor(wmOpt?.uiColor ?? .primary)
					.padding(.horizontal, 6).padding(.vertical, 2)
					.background((wmOpt?.uiColor ?? .gray).opacity(0.15)).cornerRadius(4)
				
				Text(app.contractModel)
					.font(.caption)
					.foregroundColor(cmOpt?.uiColor ?? .primary)
					.padding(.horizontal, 6).padding(.vertical, 2)
					.background((cmOpt?.uiColor ?? .gray).opacity(0.15)).cornerRadius(4)
			}
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func compLocColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(alignment: .leading, spacing: 4) {
				TextField("Pay", value: bind.pay, format: .currency(code: "EUR")).textFieldStyle(.roundedBorder)
				HStack {
					TextField("Location", text: bind.location).textFieldStyle(.roundedBorder).onSubmit {
						geocodeLocation(for: app.id, locationName: bind.wrappedValue.location)
					}
					if app.latitude != nil { Image(systemName: "mappin.circle.fill").foregroundColor(.blue).font(.caption2) }
				}
			}
		} else {
			VStack(alignment: .leading, spacing: 4) {
				Text(app.pay, format: .currency(code: "EUR")).font(.subheadline).fontWeight(.semibold)
				HStack {
					let matchedOpt = workModelOptions.first(where: { $0.value == app.workModel })
					let isRemoteWithDefault = (matchedOpt?.defaultLocation != nil && matchedOpt?.defaultLocation == app.location) || (app.workModel.lowercased().contains("remote") && app.location == defaultRemoteLocation)
					Text(isRemoteWithDefault ? defaultRemoteDisplayLabel : (app.location.isEmpty ? "No Location" : app.location)).font(.caption).foregroundColor(.secondary)
					if let lat = app.latitude, let lon = app.longitude {
						Image(systemName: "mappin.circle.fill").foregroundColor(.gray).font(.caption2).help("Geotagged: \(String(format: "%.4f", lat)), \(String(format: "%.4f", lon))")
					}
				}
			}
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func linksColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(spacing: 6) {
				TextField("Job URL", text: bind.jobLink).textFieldStyle(.roundedBorder)
				TextField("LinkedIn", text: bind.linkedInURL).textFieldStyle(.roundedBorder)
			}
		} else {
			VStack(alignment: .leading, spacing: 6) {
				if let url = safeURL(from: app.jobLink) { Link("Job Posting ↗", destination: url).foregroundColor(.blue) } else { Text("No Job Link").foregroundColor(.secondary) }
				if let url = safeURL(from: app.linkedInURL) { Link("LinkedIn ↗", destination: url).foregroundColor(.blue) } else { Text("No LinkedIn").foregroundColor(.secondary) }
			}
			.font(.caption)
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}

	@ViewBuilder private func ageObsColumn(for app: JobApplication) -> some View {
		let bind = getBinding(for: app.id)
		let statusOpt = statusOptions.first(where: { $0.value == bind.wrappedValue.status })
		let isRejected = statusOpt?.safeIsRejected == true
		if editID == app.id {
			VStack(alignment: .leading, spacing: 4) {
				Text("\(app.displayAge) days active").font(.caption).bold()
				TextField("Obs...", text: bind.observations).textFieldStyle(.roundedBorder)
			}
		} else {
			VStack(alignment: .leading, spacing: 4) {
				Text("\(app.displayAge) days active").font(.caption).fontWeight(.semibold)
				Text(app.observations).font(.caption).foregroundColor(.secondary).lineLimit(1).truncationMode(.tail)
			}
			.strikethrough(isRejected)
			.opacity(isRejected ? 0.5 : 1.0)
			.contentShape(Rectangle())
			.onTapGesture(count: 2) { editID = app.id }
		}
	}
	
	// MARK: - Toolbars and Helpers
	
	private var topFilterBar: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				Image(systemName: "line.3.horizontal.decrease.circle.fill").foregroundColor(.secondary).font(.title3)
				
				Toggle(isOn: $showActiveOnly) {
					Label("Active", systemImage: "bolt.fill")
				}
				.toggleStyle(.button)
				.tint(showActiveOnly ? .blue : .gray)
				.controlSize(.small)
				
				TextField("Filter Company...", text: $filterCompany).textFieldStyle(.roundedBorder).frame(width: 140)
				TextField("Filter Role...", text: $filterRole).textFieldStyle(.roundedBorder).frame(width: 140)
				
				MultiSelectMenu(title: "Status", options: statusOptions.map(\.value), selection: $filterStatus)
				MultiSelectMenu(title: "Model", options: workModelOptions.map(\.value), selection: $filterWorkModel)
				
				let locOpts = applications.map {
					$0.workModel.lowercased().contains("remote") ? defaultRemoteDisplayLabel : $0.location
				}.filter { !$0.isEmpty }.unique().sorted()
				MultiSelectMenu(title: "Location", options: locOpts, selection: $filterLocation)
				
				if !filterCompany.isEmpty || !filterRole.isEmpty || !filterLocation.isEmpty || !filterStatus.isEmpty || !filterWorkModel.isEmpty || showActiveOnly {
					Button("Clear All") {
						filterCompany = ""
						filterRole = ""
						filterLocation.removeAll()
						filterStatus.removeAll()
						filterWorkModel.removeAll()
						showActiveOnly = false
					}
					.buttonStyle(.bordered)
					.tint(.red)
					.controlSize(.small)
				}
			}
			.padding(.horizontal, 15)
			.padding(.vertical, 10)
		}
		.background(.regularMaterial)
		.overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.15)), alignment: .bottom)
	}
	
	private var bottomToolbar: some View {
		HStack(spacing: 12) {
			Button(action: prepareAddSheet) { Label("Add", systemImage: "plus") }
				.buttonStyle(.borderedProminent).tint(.blue)
			Button(action: { showPaste = true }) { Label("Import", systemImage: "square.and.arrow.down") }
				.buttonStyle(.bordered).tint(.blue)
			
			if editID != nil {
				Button(action: { editID = nil }) { Label("Done Editing", systemImage: "checkmark.circle.fill") }
					.buttonStyle(.borderedProminent).tint(.green)
			}
			
			Spacer()
			Text("Double-click a row to edit it inline.").font(.caption).foregroundColor(.secondary)
			Spacer()
			
			Button(action: removeSelectedApplication) { Label("Delete", systemImage: "trash") }
				.buttonStyle(.bordered).tint(.gray).disabled(editID == nil)
			Button(action: { showingDeleteAllAlert = true }) { Label("Delete All", systemImage: "trash.slash.fill") }
				.buttonStyle(.bordered).tint(.red).disabled(applications.isEmpty)
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(.regularMaterial)
		.overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.15)), alignment: .top)
	}
	
	private func prepareAddSheet() {
		let defaultModel = workModelOptions.first?.value ?? "Remote"
		let matchedOpt = workModelOptions.first(where: { $0.value == defaultModel })
		var defaultLoc = matchedOpt?.defaultLocation ?? ""
		if defaultLoc.isEmpty && defaultModel.lowercased().contains("remote") {
			defaultLoc = defaultRemoteLocation
		}
		
		newAppToSave = JobApplication(
			index: (applications.last?.index ?? 0) + 1,
			company: "", jobLink: "", role: "", status: statusOptions.first?.value ?? "1. Applied",
			isInterviewPhase: false, linkedInURL: "", appliedDate: Date(), culturalFit: 0,
			workModel: defaultModel, contractModel: contractModelOptions.first?.value ?? "Full-Time",
			pay: 0.0, location: defaultLoc, latitude: nil, longitude: nil, processAge: nil, observations: ""
		)
		showAdd = true
	}
	
	private func removeSelectedApplication() {
		if let id = editID {
			applications.removeAll { $0.id == id }
			editID = nil
		}
	}
	
	private func deleteAllApplications() {
		applications.removeAll()
		editID = nil
	}
	
	private func geocodeLocation(for appID: UUID, locationName: String) {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = locationName
		Task {
			if let response = try? await MKLocalSearch(request: request).start(), let mapItem = response.mapItems.first {
				let coord = mapItem.location.coordinate
				await MainActor.run {
					if let index = applications.firstIndex(where: { $0.id == appID }) {
						applications[index].latitude = coord.latitude
						applications[index].longitude = coord.longitude
					}
				}
			}
		}
	}
}

// MARK: - Add Application Popup Sheet
struct AddApplicationSheet: View {
	@Binding var app: JobApplication
	@Binding var applications: [JobApplication]
	@Binding var isPresented: Bool
	
	var statusOptions: [DropdownOption]
	var workModelOptions: [DropdownOption]
	var contractModelOptions: [DropdownOption]
	var defaultRemoteLocation: String
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Text("Add Application").font(.largeTitle).fontWeight(.bold)
				Spacer()
				Button("Cancel") { isPresented = false }.buttonStyle(.bordered)
				Button("Save") { saveAndGeocode() }
					.buttonStyle(.borderedProminent).tint(.blue)
					.keyboardShortcut(.defaultAction)
					.disabled(app.company.isEmpty)
			}.padding(25)
			
			Form {
				Section("Job Details") {
					TextField("Company Name", text: $app.company)
					TextField("Target Role", text: $app.role)
					TextField("Job Posting URL", text: $app.jobLink)
					TextField("LinkedIn URL", text: $app.linkedInURL)
				}
				Section("Status & Pipeline") {
					Picker("Current Status", selection: $app.status) {
						ForEach(statusOptions) { opt in Text(opt.value).tag(opt.value) }
					}
					Toggle("Currently in Interview Phase", isOn: $app.isInterviewPhase)
					DatePicker("Date Applied", selection: $app.appliedDate, displayedComponents: .date)
					HStack {
						Text("Cultural Fit:")
						StarRating(rating: $app.culturalFit)
					}
				}
				Section("Logistics & Compensation") {
					Picker("Work Model", selection: $app.workModel) {
						ForEach(workModelOptions) { opt in Text(opt.value).tag(opt.value) }
					}.onChange(of: app.workModel) { old, new in
						let matchedOpt = workModelOptions.first(where: { $0.value == new })
						if let defLoc = matchedOpt?.defaultLocation, !defLoc.isEmpty {
							app.location = defLoc
						} else if new.lowercased().contains("remote") && !defaultRemoteLocation.isEmpty {
							app.location = defaultRemoteLocation
						}
					}
					Picker("Contract Type", selection: $app.contractModel) {
						ForEach(contractModelOptions) { opt in Text(opt.value).tag(opt.value) }
					}
					TextField("Target Pay (EUR)", value: $app.pay, format: .currency(code: "EUR"))
					TextField("Location", text: $app.location)
				}
				Section("Observations") {
					TextEditor(text: $app.observations)
						.frame(height: 80)
						.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.2)))
				}
			}
			.formStyle(.grouped)
			.padding(.horizontal, 10)
		}
		.frame(width: 500, height: 680)
		.background(.ultraThinMaterial)
	}
	
	private func saveAndGeocode() {
		applications.append(app)
		let savedId = app.id
		isPresented = false
		
		if !app.location.isEmpty {
			let request = MKLocalSearch.Request()
			request.naturalLanguageQuery = app.location
			Task {
				if let response = try? await MKLocalSearch(request: request).start(), let mapItem = response.mapItems.first {
					let coord = mapItem.location.coordinate
					await MainActor.run {
						if let index = applications.firstIndex(where: { $0.id == savedId }) {
							applications[index].latitude = coord.latitude
							applications[index].longitude = coord.longitude
						}
					}
				}
			}
		}
	}
}

// MARK: - Smart CSV/TSV Importer
struct PasteImportView: View {
	@Binding var applications: [JobApplication]
	@Binding var isPresented: Bool
	
	var statusOptions: [DropdownOption]
	var workModelOptions: [DropdownOption]
	var contractModelOptions: [DropdownOption]
	var defaultRemoteLocation: String
	
	@State private var pastedText = ""
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Smart Bulk Import").font(.largeTitle).fontWeight(.bold)
			Text("Export your Google Sheet as a CSV (.csv), open it in TextEdit/Notepad, and paste the text below. Or paste directly from Excel.")
				.foregroundColor(.secondary)
			
			VStack(alignment: .leading, spacing: 5) {
				Text("⚠️ Your spreadsheet columns MUST be in this exact order (left to right):")
					.font(.caption).fontWeight(.bold).foregroundColor(.orange)
				Text("Company | Role | Status | Fit (1-5) | Work Model | Contract | Pay | Location | Job Link | LinkedIn | Date Applied")
					.font(.system(.caption, design: .monospaced))
					.padding(8)
					.background(.orange.opacity(0.1))
					.cornerRadius(6)
			}
			
			TextEditor(text: $pastedText)
				.font(.system(.body, design: .monospaced))
				.padding(4)
				.background(Color.primary.opacity(0.05))
				.cornerRadius(8)
				.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
			
			HStack {
				Button("Cancel") { isPresented = false }
					.keyboardShortcut(.cancelAction)
				Spacer()
				Button("Parse & Import") {
					parseAndImport()
					isPresented = false
				}
				.buttonStyle(.borderedProminent)
				.disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
		}
		.padding(30)
		.frame(width: 800, height: 500)
		.background(.ultraThinMaterial)
	}
	
	private func parseCSVLine(_ line: String) -> [String] {
		var result: [String] = []
		var current = ""
		var inQuotes = false
		
		for char in line {
			if char == "\"" {
				inQuotes.toggle()
			} else if char == "," && !inQuotes {
				result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
				current = ""
			} else {
				current.append(char)
			}
		}
		result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
		return result
	}
	
	private func parseAndImport() {
		let rows = pastedText.components(separatedBy: .newlines)
		var newApps: [JobApplication] = []
		var nextIndex = (applications.last?.index ?? 0) + 1
		
		for row in rows {
			if row.trimmingCharacters(in: .whitespaces).isEmpty { continue }
			
			var cols: [String] = []
			if row.contains("\t") {
				cols = row.components(separatedBy: "\t").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			} else {
				cols = parseCSVLine(row)
			}
			
			if cols.count > 3, Int(cols[0]) != nil {
				cols.removeFirst()
			}
			
			if cols.count >= 1 {
				let companyText = cols[0]
				if companyText.isEmpty { continue }
				
				let roleText = cols.count > 1 ? cols[1] : ""
				let statusText = cols.count > 2 && !cols[2].isEmpty ? cols[2] : (statusOptions.first?.value ?? "1. Applied")
				let fitRaw = cols.count > 3 ? cols[3] : "0"
				let fit = Int(fitRaw.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
				let workText = cols.count > 4 && !cols[4].isEmpty ? cols[4] : (workModelOptions.first?.value ?? "Remote")
				let contractText = cols.count > 5 && !cols[5].isEmpty ? cols[5] : (contractModelOptions.first?.value ?? "Full-Time")
				
				var payValue = 0.0
				if cols.count > 6 {
					let cleanPay = cols[6].replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
					payValue = Double(cleanPay) ?? 0.0
				}
				
				var locationText = cols.count > 7 ? cols[7] : ""
				let matchedOpt = workModelOptions.first(where: { $0.value == workText })
				if let defLoc = matchedOpt?.defaultLocation, !defLoc.isEmpty {
					locationText = defLoc
				} else if workText.lowercased().contains("remote") && !defaultRemoteLocation.isEmpty {
					locationText = defaultRemoteLocation
				}
				
				let linkText = cols.count > 8 ? cols[8] : ""
				let linkedinText = cols.count > 9 ? cols[9] : ""
				let dateRaw = cols.count > 10 ? cols[10] : ""
				
				var appliedDate = Date()
				if let parsedDate = parseDate(dateRaw) {
					appliedDate = parsedDate
				}
				
				newApps.append(JobApplication(
					index: nextIndex,
					company: companyText,
					jobLink: linkText,
					role: roleText,
					status: statusText,
					isInterviewPhase: false,
					linkedInURL: linkedinText,
					appliedDate: appliedDate,
					culturalFit: fit,
					workModel: workText,
					contractModel: contractText,
					pay: payValue,
					location: locationText,
					latitude: nil,
					longitude: nil,
					processAge: nil,
					observations: ""
				))
				nextIndex += 1
			}
		}
		
		applications.append(contentsOf: newApps)
		
		let appsToGeocode = newApps.filter { !$0.location.isEmpty }
		
		Task {
			for app in appsToGeocode {
				let request = MKLocalSearch.Request()
				request.naturalLanguageQuery = app.location
				if let response = try? await MKLocalSearch(request: request).start(), let mapItem = response.mapItems.first {
					let coord = mapItem.location.coordinate
					await MainActor.run {
						if let idx = self.applications.firstIndex(where: { $0.id == app.id }) {
							self.applications[idx].latitude = coord.latitude
							self.applications[idx].longitude = coord.longitude
						}
					}
				}
				try? await Task.sleep(nanoseconds: 2_000_000_000)
			}
		}
	}
	
	private func parseDate(_ raw: String) -> Date? {
		let formatter = DateFormatter()
		let formats = ["dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd", "dd-MM-yyyy"]
		for format in formats {
			formatter.dateFormat = format
			if let d = formatter.date(from: raw) { return d }
		}
		return nil
	}
}

// MARK: - 7. Documents View
struct DocumentsView: View {
	@Binding var documents: [StoredDocument]
	var docClassifications: [DropdownOption]
	var applications: [JobApplication]
	
	@State private var showingFileImporter = false
	@State private var selectedDocID: StoredDocument.ID?
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Spacer()
				Button(action: { showingFileImporter = true }) {
					Label("Import Document", systemImage: "tray.and.arrow.down.fill")
				}.buttonStyle(.borderedProminent).tint(.gray)
			}
			.padding([.horizontal, .top], 20)
			.padding(.bottom, 10)
			
			Table($documents, selection: $selectedDocID) {
				TableColumn("File Name") { $doc in
					HStack {
						Image(systemName: "doc.text.fill").foregroundColor(.secondary)
						TextField("Name", text: $doc.name).textFieldStyle(.plain)
					}
				}
				TableColumn("Classification") { $doc in
					Picker("", selection: $doc.classification.toUnwrapped(default: docClassifications.first?.value ?? "General")) {
						ForEach(docClassifications) { opt in Text(opt.value).tag(opt.value) }
					}
					.labelsHidden()
					.padding(4)
					.background(docClassifications.first(where: { $0.value == doc.classification })?.uiColor.opacity(0.15) ?? Color.gray.opacity(0.15))
					.cornerRadius(6)
				}
				TableColumn("Linked App") { $doc in
					Picker("", selection: $doc.linkedApplicationID) {
						Text("None").tag(UUID?(nil))
						ForEach(applications) { app in
							Text("\(app.company) (\(app.role))").tag(UUID?(app.id))
						}
					}
					.labelsHidden()
				}
				TableColumn("File Path") { $doc in
					Text(doc.fileURL.lastPathComponent).foregroundColor(.secondary)
				}
				TableColumn("Date Added") { $doc in
					Text(doc.dateAdded, style: .date)
				}
			}
			.scrollContentBackground(.hidden)
			.background(Color.white.opacity(0.15))
			.padding(.horizontal, 15)
			
			Divider()
			
			HStack {
				Button(action: removeSelectedDocument) {
					Image(systemName: "minus")
				}
				.buttonStyle(.plain)
				.padding(8)
				.disabled(selectedDocID == nil)
				
				Spacer()
				Text("\(documents.count) Documents").font(.caption).foregroundColor(.secondary)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			.background(.ultraThinMaterial)
		}
		.fileImporter(
			isPresented: $showingFileImporter,
			allowedContentTypes: [.pdf, .plainText, .rtf, .data],
			allowsMultipleSelection: false
		) { result in
			importDocument(from: result)
		}
	}
	
	private func importDocument(from result: Result<[URL], Error>) {
		if let selectedFile = try? result.get().first {
			documents.append(StoredDocument(
				name: selectedFile.deletingPathExtension().lastPathComponent,
				fileURL: selectedFile,
				dateAdded: Date(),
				classification: docClassifications.first?.value ?? "General",
				linkedApplicationID: nil
			))
		}
	}
	
	private func removeSelectedDocument() {
		if let id = selectedDocID {
			documents.removeAll { $0.id == id }
			selectedDocID = nil
		}
	}
}

// MARK: - 8. Settings View
struct SettingsView: View {
	@Binding var roleRules: [RegexRule]
	@Binding var seniorityRules: [RegexRule]
	@Binding var statusOptions: [DropdownOption]
	@Binding var workModelOptions: [DropdownOption]
	@Binding var contractModelOptions: [DropdownOption]
	@Binding var docClassifications: [DropdownOption]
	@Binding var defaultRemoteLocation: String
	@Binding var defaultRemoteDisplayLabel: String
	
	let gridColumns = [GridItem(.adaptive(minimum: 400), spacing: 20)]
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 30) {
				VStack(alignment: .leading, spacing: 8) {
					Text("Customize your underlying engine logic and UI rendering.").foregroundColor(.secondary)
				}
				.padding([.top, .leading, .trailing], 25)
				
				VStack(alignment: .leading, spacing: 15) {
					Label("Global Remote Settings", systemImage: "globe.americas.fill").font(.title2).fontWeight(.semibold).foregroundColor(.blue)
					Text("When you select 'Remote' as a Work Model, these defaults are used.").font(.caption).foregroundColor(.secondary)
					
					HStack(spacing: 20) {
						ModernTextField(label: "Map Geocode Target", placeholder: "e.g. Valongo, PT", text: $defaultRemoteLocation, icon: "mappin.circle.fill")
						ModernTextField(label: "Summary Table Label", placeholder: "e.g. Remote", text: $defaultRemoteDisplayLabel, icon: "tag.fill")
					}
					.padding(20)
					.background(.regularMaterial)
					.clipShape(RoundedRectangle(cornerRadius: 16))
					.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
					.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
				}
				.padding(.horizontal, 30)
				
				Divider().padding(.horizontal, 30).padding(.vertical, 10)
				
				VStack(alignment: .leading, spacing: 15) {
					Label("Smart Tags Engine", systemImage: "brain.head.profile").font(.title2).fontWeight(.semibold).foregroundColor(.blue)
					Text("These regex patterns automatically assign tags when you type a Role name.").font(.caption).foregroundColor(.secondary)
					
					LazyVGrid(columns: gridColumns, spacing: 20) {
						RuleEditor(title: "Role Type Mapping", icon: "briefcase.fill", rules: $roleRules)
						RuleEditor(title: "Seniority Mapping", icon: "star.fill", rules: $seniorityRules)
					}
				}
				.padding(.horizontal, 30)
				
				Divider().padding(.horizontal, 30).padding(.vertical, 10)
				
				VStack(alignment: .leading, spacing: 15) {
					Label("Dropdown Menus", systemImage: "list.dash").font(.title2).fontWeight(.semibold).foregroundColor(.blue)
					Text("Customize the options available in table pickers, plus their row highlighting rules.").font(.caption).foregroundColor(.secondary)
					
					LazyVGrid(columns: gridColumns, spacing: 20) {
						DropdownEditor(title: "Status Pipeline", icon: "arrow.triangle.pull", options: $statusOptions)
						DropdownEditor(title: "Work Models", icon: "building.2", options: $workModelOptions)
						DropdownEditor(title: "Contract Models", icon: "doc.text", options: $contractModelOptions)
						DropdownEditor(title: "Doc Classifications", icon: "folder.fill", options: $docClassifications)
					}
				}
				.padding(.horizontal, 30)
				.padding(.bottom, 40)
			}
		}
	}
}

struct RuleEditor: View {
	var title: String
	var icon: String
	@Binding var rules: [RegexRule]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Label(title, systemImage: icon).font(.headline).padding(.bottom, 5)
			
			VStack(spacing: 0) {
				ForEach($rules) { $rule in
					let index = rules.firstIndex(where: { $0.id == rule.id }) ?? 0
					
					HStack(spacing: 8) {
						TextField("Regex", text: $rule.pattern)
							.font(.system(.caption, design: .monospaced))
							.textFieldStyle(.plain)
							.padding(8)
							.background(Color.primary.opacity(0.05))
							.cornerRadius(6)
							.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2), lineWidth: 1))
						
						Image(systemName: "arrow.right").foregroundColor(.secondary)
						
						TextField("Tag", text: $rule.outputName)
							.textFieldStyle(.plain)
							.padding(8)
							.background(Color.primary.opacity(0.05))
							.cornerRadius(6)
							.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2), lineWidth: 1))
						
						VStack(spacing: 2) {
							Button(action: { if index > 0 { rules.swapAt(index, index - 1) } }) {
								Image(systemName: "chevron.up").font(.system(size: 8))
							}.buttonStyle(.plain).disabled(index == 0)
							
							Button(action: { if index < rules.count - 1 { rules.swapAt(index, index + 1) } }) {
								Image(systemName: "chevron.down").font(.system(size: 8))
							}.buttonStyle(.plain).disabled(index == rules.count - 1)
						}.foregroundColor(.secondary)
						
						Button(action: { rules.remove(at: index) }) {
							Image(systemName: "trash").foregroundColor(.red)
						}.buttonStyle(.plain).padding(.leading, 4)
					}
					.padding(.horizontal, 10)
					.padding(.vertical, 6)
					
					Divider()
				}
			}
			.background(.regularMaterial)
			.cornerRadius(12)
			.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
			
			Button(action: { rules.append(RegexRule(pattern: "", outputName: "")) }) {
				Label("Add Rule", systemImage: "plus")
			}.buttonStyle(.bordered).controlSize(.small)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.padding(20)
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}

struct DropdownEditor: View {
	var title: String
	var icon: String
	@Binding var options: [DropdownOption]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Label(title, systemImage: icon).font(.headline).padding(.bottom, 5)
			
			VStack(spacing: 0) {
				ForEach($options) { $option in
					let index = options.firstIndex(where: { $0.id == option.id }) ?? 0
					
					VStack(alignment: .leading, spacing: 5) {
						HStack(spacing: 8) {
							TextField("Value", text: $option.value)
								.textFieldStyle(.plain)
								.padding(8)
								.background(Color.primary.opacity(0.05))
								.cornerRadius(6)
								.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2), lineWidth: 1))
								.foregroundColor($option.wrappedValue.uiColor)
								.fontWeight($option.wrappedValue.safeIsBold ? .bold : .regular)
								.strikethrough($option.wrappedValue.safeIsRejected)
							
							Picker("", selection: $option.colorName.toUnwrapped(default: "Primary")) {
								ForEach(DropdownOption.availableColors, id: \.self) { color in
									Text(color).tag(color)
								}
							}
							.frame(width: 90)
							.labelsHidden()
							
							Toggle("B", isOn: $option.isBold.toUnwrapped(default: false))
								.toggleStyle(.button)
								.font(.caption.bold())
								.frame(width: 30)
							
							if title == "Status Pipeline" {
								Toggle(isOn: $option.isRejected.toUnwrapped(default: false)) {
									Image(systemName: "strikethrough")
								}
								.toggleStyle(.button)
								.font(.caption.bold())
								.frame(width: 30)
							}
							
							VStack(spacing: 2) {
								Button(action: { if index > 0 { options.swapAt(index, index - 1) } }) {
									Image(systemName: "chevron.up").font(.system(size: 8))
								}.buttonStyle(.plain).disabled(index == 0)
								
								Button(action: { if index < options.count - 1 { options.swapAt(index, index + 1) } }) {
									Image(systemName: "chevron.down").font(.system(size: 8))
								}.buttonStyle(.plain).disabled(index == options.count - 1)
							}.foregroundColor(.secondary)
							
							Button(action: { options.remove(at: index) }) {
								Image(systemName: "trash").foregroundColor(.red)
							}.buttonStyle(.plain).padding(.leading, 4)
						}
						
						if title == "Work Models" {
							HStack {
								Image(systemName: "mappin.circle.fill").foregroundColor(.secondary)
								TextField("Default Map Target (Optional)", text: $option.defaultLocation.toUnwrapped(default: ""))
									.textFieldStyle(.plain)
									.font(.caption)
									.padding(4)
									.background(Color.primary.opacity(0.05))
									.cornerRadius(4)
									.overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2), lineWidth: 1))
							}
							.padding(.leading, 4)
							.padding(.bottom, 4)
						}
					}
					.padding(.horizontal, 10)
					.padding(.vertical, 6)
					
					Divider()
				}
			}
			.background(.regularMaterial)
			.cornerRadius(12)
			.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
			
			Button(action: { options.append(DropdownOption(value: "New Option", colorName: "Primary", isBold: false)) }) {
				Label("Add Option", systemImage: "plus")
			}.buttonStyle(.bordered).controlSize(.small)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.padding(20)
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
	}
}
