import SwiftUI

// MARK: - Admin Users Management

struct AdminUsersView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedUserType: User.UserType? = nil
    @State private var selectedUser: User? = nil
    @State private var showingUserDetail = false
    
    private var filteredUsers: [User] {
        let users = dataManager.usersState.items
        
        let typeFiltered = selectedUserType.map { type in
            users.filter { $0.userType == type }
        } ?? users
        
        guard !searchText.isEmpty else { return typeFiltered }
        
        return typeFiltered.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Поиск и фильтры
            VStack(spacing: AppConstants.Spacing.medium) {
                SearchBar(text: $searchText)
                
                UserTypeFilter(selectedType: $selectedUserType)
            }
            .padding()
            
            Group {
                if dataManager.usersState.isLoading {
                    ProgressView("Загрузка пользователей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredUsers.isEmpty {
                    EmptyUsersView()
                } else {
                    List {
                        ForEach(filteredUsers, id: \.id) { user in
                            AdminUserRow(user: user) {
                                selectedUser = user
                                showingUserDetail = true
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Пользователи (\(filteredUsers.count))")
        .sheet(item: $selectedUser) { user in
            AdminUserDetailView(user: user)
        }
        .task {
            await dataManager.loadDataType(.users)
        }
    }
}

struct UserTypeFilter: View {
    @Binding var selectedType: User.UserType?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Spacing.medium) {
                FilterButton(title: "Все", isSelected: selectedType == nil) {
                    selectedType = nil
                }
                
                ForEach(User.UserType.allCases, id: \.self) { type in
                    FilterButton(
                        title: type.displayName,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct EmptyUsersView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Пользователи не найдены")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Попробуйте изменить критерии поиска")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct AdminUserRow: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.Spacing.medium) {
                Circle()
                    .fill(AppConstants.Colors.primary.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(user.name.prefix(1))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(user.userType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(user.points) баллов")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.primary)
                            .fontWeight(.medium)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(user.isActive ? "Активен" : "Заблокирован")
                            .font(.caption)
                            .foregroundColor(user.isActive ? .green : AppConstants.Colors.primary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminUserDetailView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @State private var editedUser: User
    @State private var isEditing = false
    
    init(user: User) {
        self.user = user
        self._editedUser = State(initialValue: user)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    // Аватар пользователя
                    Circle()
                        .fill(AppConstants.Colors.primary.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(editedUser.name.prefix(1))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppConstants.Colors.primary)
                        )
                    
                    VStack(spacing: AppConstants.Spacing.medium) {
                        if isEditing {
                            VStack(spacing: AppConstants.Spacing.medium) {
                                TextField("Имя", text: $editedUser.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Email", text: $editedUser.email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                
                                TextField("Телефон", text: $editedUser.phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                                
                                Stepper("Баллы: \(editedUser.points)", value: $editedUser.points, in: 0...99999)
                                
                                Toggle("Активный пользователь", isOn: $editedUser.isActive)
                                    .tint(AppConstants.Colors.primary)
                            }
                        } else {
                            UserInfoDisplay(user: editedUser)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Пользователь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Сохранить") {
                            // Здесь должна быть логика сохранения
                            isEditing = false
                        }
                    } else {
                        Button("Изменить") {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }
}

struct UserInfoDisplay: View {
    let user: User
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            InfoCard(title: "Основная информация") {
                VStack(spacing: AppConstants.Spacing.small) {
                    InfoRow(label: "Имя", value: user.name)
                    InfoRow(label: "Email", value: user.email)
                    InfoRow(label: "Телефон", value: user.phone)
                    InfoRow(label: "Тип пользователя", value: user.userType.displayName)
                    InfoRow(label: "Роль", value: user.role.displayName)
                }
            }
            
            InfoCard(title: "Статистика") {
                VStack(spacing: AppConstants.Spacing.small) {
                    InfoRow(label: "Баллы", value: "\(user.points)")
                    InfoRow(label: "Дата регистрации", value: user.registrationDate.formattedDate())
                    InfoRow(label: "Статус", value: user.isActive ? "Активен" : "Заблокирован")
                }
            }
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Admin Cars Management

struct AdminCarsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddCar = false
    @State private var selectedCar: Car? = nil
    @State private var searchText = ""
    
    private var filteredCars: [Car] {
        if searchText.isEmpty {
            return dataManager.carsState.items.sorted(by: { $0.createdAt > $1.createdAt })
        }
        return dataManager.carsState.items.filter { car in
            car.brand.localizedCaseInsensitiveContains(searchText) ||
            car.model.localizedCaseInsensitiveContains(searchText)
        }.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding()
            
            Group {
                if dataManager.carsState.isLoading {
                    ProgressView("Загрузка автомобилей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredCars.isEmpty {
                    EmptyCarsView()
                } else {
                    List {
                        ForEach(filteredCars, id: \.id) { car in
                            AdminCarRow(car: car) {
                                selectedCar = car
                            }
                        }
                        .onDelete(perform: deleteCars)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Автомобили (\(filteredCars.count))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddCar = true
                }
                .foregroundColor(AppConstants.Colors.primary)
            }
        }
        .sheet(isPresented: $showingAddCar) {
            AdminCarEditView(car: nil)
        }
        .sheet(item: $selectedCar) { car in
            AdminCarEditView(car: car)
        }
        .task {
            await dataManager.loadDataType(.cars)
        }
    }
    
    private func deleteCars(at offsets: IndexSet) {
        for index in offsets {
            let car = filteredCars[index]
            dataManager.deleteCar(car.id)
        }
    }
}

struct EmptyCarsView: View {
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "car")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Автомобили не найдены")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Добавьте автомобили в каталог")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct AdminCarRow: View {
    let car: Car
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.Spacing.medium) {
                if let imageData = car.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 45)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 60, height: 45)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: AppConstants.Images.car)
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(car.brand) \(car.model)")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(car.year) год")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(car.price)
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.primary)
                            .fontWeight(.medium)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(car.isActive ? "Активен" : "Скрыт")
                            .font(.caption)
                            .foregroundColor(car.isActive ? .green : AppConstants.Colors.primary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminCarEditView: View {
    let car: Car?
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var brand = ""
    @State private var model = ""
    @State private var year = ""
    @State private var price = ""
    @State private var description = ""
    @State private var isActive = true
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    // Характеристики
    @State private var engine = ""
    @State private var transmission = ""
    @State private var fuelType = ""
    @State private var bodyType = ""
    @State private var drivetrain = ""
    @State private var color = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    ImagePickerSection(
                        selectedImage: $selectedImage,
                        showingImagePicker: $showingImagePicker,
                        existingImageData: car?.imageData,
                        placeholder: "car.fill"
                    )
                    
                    CarBasicInfoSection(
                        brand: $brand,
                        model: $model,
                        year: $year,
                        price: $price,
                        description: $description
                    )
                    
                    CarSpecificationsEditSection(
                        engine: $engine,
                        transmission: $transmission,
                        fuelType: $fuelType,
                        bodyType: $bodyType,
                        drivetrain: $drivetrain,
                        color: $color
                    )
                    
                    Toggle("Активен", isOn: $isActive)
                        .tint(AppConstants.Colors.primary)
                    
                    Button(car == nil ? "Добавить автомобиль" : "Сохранить изменения") {
                        saveCar()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? AppConstants.Colors.primary : Color.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle(car == nil ? "Новый автомобиль" : "Редактировать авто")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                if let car = car {
                    loadCarData(car)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !brand.isEmpty && !model.isEmpty && !year.isEmpty && !price.isEmpty
    }
    
    private func loadCarData(_ car: Car) {
        brand = car.brand
        model = car.model
        year = String(car.year)
        price = car.price
        description = car.description
        isActive = car.isActive
        engine = car.specifications.engine
        transmission = car.specifications.transmission
        fuelType = car.specifications.fuelType
        bodyType = car.specifications.bodyType
        drivetrain = car.specifications.drivetrain
        color = car.specifications.color
    }
    
    private func saveCar() {
        guard let yearInt = Int(year) else { return }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        let specifications = Car.CarSpecifications(
            engine: engine,
            transmission: transmission,
            fuelType: fuelType,
            bodyType: bodyType,
            drivetrain: drivetrain,
            color: color
        )
        
        if let existingCar = car {
            let updatedCar = Car(
                id: existingCar.id,
                brand: brand,
                model: model,
                year: yearInt,
                price: price,
                imageURL: existingCar.imageURL,
                description: description,
                specifications: specifications,
                isActive: isActive,
                createdAt: existingCar.createdAt,
                imageData: imageData ?? existingCar.imageData
            )
            dataManager.updateCar(updatedCar)
        } else {
            let newCar = Car(
                id: UUID().uuidString,
                brand: brand,
                model: model,
                year: yearInt,
                price: price,
                imageURL: "",
                description: description,
                specifications: specifications,
                isActive: isActive,
                createdAt: Date(),
                imageData: imageData
            )
            dataManager.addCar(newCar)
        }
        
        dismiss()
    }
}

struct CarBasicInfoSection: View {
    @Binding var brand: String
    @Binding var model: String
    @Binding var year: String
    @Binding var price: String
    @Binding var description: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            TextField("Марка", text: $brand)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Модель", text: $model)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Год", text: $year)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            TextField("Цена", text: $price)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                Text("Описание")
                    .font(.headline)
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

struct CarSpecificationsEditSection: View {
    @Binding var engine: String
    @Binding var transmission: String
    @Binding var fuelType: String
    @Binding var bodyType: String
    @Binding var drivetrain: String
    @Binding var color: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Характеристики")
                .font(.headline)
            
            VStack(spacing: AppConstants.Spacing.medium) {
                TextField("Двигатель", text: $engine)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Коробка передач", text: $transmission)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Тип топлива", text: $fuelType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Тип кузова", text: $bodyType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Привод", text: $drivetrain)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Цвет", text: $color)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct ImagePickerSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var showingImagePicker: Bool
    let existingImageData: Data?
    let placeholder: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text("Изображение")
                .font(.headline)
            
            Button(action: { showingImagePicker = true }) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } else if let existingImageData = existingImageData, let image = UIImage(data: existingImageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 200)
                        .cornerRadius(12)
                        .overlay(
                            VStack {
                                Image(systemName: placeholder)
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("Нажмите для выбора")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdminUsersView()
            .environmentObject(DataManager())
    }
}
