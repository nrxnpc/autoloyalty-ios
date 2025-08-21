import SwiftUI

struct CarTinderView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentIndex = 0
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var showingPriceRequest = false
    @State private var selectedCar: Car?
    @State private var likedCars: Set<String> = []
    
    private var availableCars: [Car] {
        dataManager.carsState.items.filter { $0.isActive }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Карточки автомобилей
            ZStack {
                if currentIndex < availableCars.count {
                    // Показываем следующую карточку под текущей
                    if currentIndex + 1 < availableCars.count {
                        CarCard(car: availableCars[currentIndex + 1])
                            .scaleEffect(0.9)
                            .opacity(0.5)
                    }
                    
                    // Текущая карточка с анимациями
                    CarCard(car: availableCars[currentIndex])
                        .offset(offset)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(getScaleAmount())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                    rotation = Double(value.translation.width / 20)
                                }
                                .onEnded { value in
                                    withAnimation(.spring()) {
                                        if abs(value.translation.width) > 100 {
                                            // Свайп влево или вправо
                                            swipeCard(direction: value.translation.width > 0 ? .right : .left)
                                        } else {
                                            // Возврат в исходное положение
                                            offset = .zero
                                            rotation = 0
                                        }
                                    }
                                }
                        )
                } else {
                    // Нет больше карточек
                    EmptyCardsView(likedCarIds: Array(likedCars)) {
                        withAnimation {
                            currentIndex = 0
                            likedCars.removeAll()
                        }
                    }
                }
            }
            .frame(height: 600)
            
            Spacer()
            
            // Кнопки действий
            if currentIndex < availableCars.count {
                CarActionButtons(
                    onDislike: {
                        withAnimation(.spring()) {
                            swipeCard(direction: .left)
                        }
                    },
                    onPriceRequest: {
                        selectedCar = availableCars[currentIndex]
                        showingPriceRequest = true
                    },
                    onLike: {
                        withAnimation(.spring()) {
                            swipeCard(direction: .right)
                        }
                    }
                )
                .padding(.bottom, AppConstants.Spacing.extraLarge)
            }
        }
        .padding()
        .navigationTitle("Автотиндер")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: LikedCarsView(likedCarIds: Array(likedCars))) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(AppConstants.Colors.primary)
                        Text("\(likedCars.count)")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingPriceRequest) {
            if let car = selectedCar {
                PriceRequestView(car: car)
            }
        }
        .task {
            await dataManager.loadDataType(.cars)
        }
    }
    
    private func getScaleAmount() -> CGFloat {
        let max = UIScreen.main.bounds.width / 2
        let currentAmount = abs(offset.width)
        let percentage = currentAmount / max
        return 1.0 - min(percentage, 0.1)
    }
    
    private func swipeCard(direction: SwipeDirection) {
        let screenWidth = UIScreen.main.bounds.width
        
        if currentIndex < availableCars.count {
            let currentCar = availableCars[currentIndex]
            
            if direction == .right {
                likedCars.insert(currentCar.id)
            }
        }
        
        offset = CGSize(
            width: direction == .right ? screenWidth : -screenWidth,
            height: 0
        )
        rotation = direction == .right ? 25 : -25
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            rotation = 0
        }
    }
    
    enum SwipeDirection {
        case left, right
    }
}

struct CarActionButtons: View {
    let onDislike: () -> Void
    let onPriceRequest: () -> Void
    let onLike: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            CarActionButton(
                icon: "xmark",
                color: .red,
                action: onDislike
            )
            
            CarActionButton(
                icon: "questionmark.circle.fill",
                color: .blue,
                action: onPriceRequest
            )
            
            CarActionButton(
                icon: "heart.fill",
                color: .green,
                action: onLike
            )
        }
    }
}

struct CarActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}

struct EmptyCardsView: View {
    let likedCarIds: [String]
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.large) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Больше автомобилей нет")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Вы просмотрели все доступные автомобили")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: AppConstants.Spacing.medium) {
                NavigationLink("Понравившиеся авто", destination: LikedCarsView(likedCarIds: likedCarIds))
                    .padding()
                    .background(AppConstants.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                
                Button("Начать сначала", action: onRestart)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct CarCard: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Изображение автомобиля
            ZStack {
                if let imageData = car.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                } else {
                    CarPlaceholderView(car: car)
                        .frame(height: 300)
                }
                
                // Градиентная накладка снизу
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .clipped()
            }
            .cornerRadius(20, corners: [.topLeft, .topRight])
            
            // Информация об автомобиле
            CarInfoSection(car: car)
                .padding(AppConstants.Spacing.large)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct CarPlaceholderView: View {
    let car: Car
    
    var body: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay(
                VStack {
                    Image(systemName: AppConstants.Images.car)
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("\(car.brand) \(car.model)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            )
    }
}

struct CarInfoSection: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(car.brand) \(car.model)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(String(car.year)) год")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(car.price)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.Colors.primary)
            }
            
            Text(car.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Характеристики
            CarSpecificationsView(specifications: car.specifications)
        }
    }
}

struct CarSpecificationsView: View {
    let specifications: Car.CarSpecifications
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            HStack {
                SpecificationItem(icon: "engine.combustion", text: specifications.engine)
                Spacer()
                SpecificationItem(icon: "gear", text: specifications.transmission)
            }
            
            HStack {
                SpecificationItem(icon: "fuelpump", text: specifications.fuelType)
                Spacer()
                SpecificationItem(icon: "car", text: specifications.bodyType)
            }
        }
    }
}

struct SpecificationItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct LikedCarsView: View {
    let likedCarIds: [String]
    @EnvironmentObject var dataManager: DataManager
    
    private var likedCars: [Car] {
        dataManager.carsState.items.filter { likedCarIds.contains($0.id) }
    }
    
    var body: some View {
        List {
            ForEach(likedCars, id: \.id) { car in
                LikedCarRow(car: car)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Понравившиеся авто")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LikedCarRow: View {
    let car: Car
    @State private var showingPriceRequest = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack(spacing: AppConstants.Spacing.medium) {
                // Изображение автомобиля
                if let imageData = car.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 80, height: 60)
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
                    
                    Text("\(String(car.year)) год")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(car.price)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.primary)
                }
                
                Spacer()
            }
            
            Button("Запросить цену") {
                showingPriceRequest = true
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(AppConstants.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingPriceRequest) {
            PriceRequestView(car: car)
        }
    }
}

struct PriceRequestView: View {
    let car: Car
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Spacing.large) {
                // Информация об автомобиле
                VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
                    Text("Запрос цены")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: AppConstants.Spacing.medium) {
                        if let imageData = car.imageData, let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 100, height: 80)
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
                            
                            Text("\(String(car.year)) год")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(car.price)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppConstants.Colors.primary)
                        }
                        
                        Spacer()
                    }
                }
                
                // Поле для сообщения
                VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                    Text("Дополнительная информация (необязательно)")
                        .font(.headline)
                    
                    TextEditor(text: $message)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Информация о пользователе
                UserContactInfoView()
                
                Spacer()
                
                // Кнопка отправки
                Button("Отправить запрос") {
                    _ = dataManager.createPriceRequest(
                        userId: authViewModel.currentUser?.id ?? "",
                        car: car,
                        message: message.isEmpty ? nil : message
                    )
                    showingSuccessAlert = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Запрос цены")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Запрос отправлен!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Дилер получит ваш запрос и свяжется с вами в ближайшее время.")
            }
        }
    }
}

struct UserContactInfoView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Text("Ваши контактные данные будут переданы дилеру:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Имя: \(authViewModel.currentUser?.name ?? "")")
                    .font(.subheadline)
                
                Text("Email: \(authViewModel.currentUser?.email ?? "")")
                    .font(.subheadline)
                
                Text("Телефон: \(authViewModel.currentUser?.phone ?? "")")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationStack {
        CarTinderView()
            .environmentObject(AuthViewModel())
            .environmentObject(DataManager())
    }
}
