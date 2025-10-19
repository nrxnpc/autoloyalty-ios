import SwiftUI

// MARK: - Support Chat

struct SupportChatView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var messageText = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SupportChatHeader()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppConstants.Spacing.medium) {
                        // Приветственное сообщение
                        WelcomeMessage()
                        
                        // Сообщения чата
                        ForEach(messages, id: \.id) { message in
                            SupportMessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            // Input area
            SupportChatInputArea(
                messageText: $messageText,
                showingImagePicker: $showingImagePicker,
                onSend: sendMessage
            )
        }
        .navigationTitle("Поддержка")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onAppear {
            loadDemoMessages()
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Симуляция ответа поддержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let supportResponse = ChatMessage(
                id: UUID().uuidString,
                content: "Спасибо за ваше сообщение! Наш специалист рассмотрит ваш вопрос и ответит в ближайшее время.",
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(supportResponse)
        }
    }
    
    private func loadDemoMessages() {
        messages = [
            ChatMessage(
                id: "1",
                content: "Здравствуйте! Как дела с заказом?",
                isFromUser: true,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            ChatMessage(
                id: "2",
                content: "Добрый день! Ваш заказ находится в обработке. Мы уведомим вас о готовности к отправке.",
                isFromUser: false,
                timestamp: Date().addingTimeInterval(-3500)
            )
        ]
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct SupportChatHeader: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "headphones")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Техподдержка Автолояльность")
                    .font(.headline)
                
                Text("Онлайн")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}

struct WelcomeMessage: View {
    var body: some View {
        SupportMessageBubble(
            message: ChatMessage(
                id: "welcome",
                content: "Добро пожаловать в службу поддержки Автолояльность! Как мы можем вам помочь?",
                isFromUser: false,
                timestamp: Date().addingTimeInterval(-7200)
            )
        )
    }
}

struct SupportMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, AppConstants.Spacing.medium)
                    .padding(.vertical, 10)
                    .background(message.isFromUser ? AppConstants.Colors.primary : Color.secondary.opacity(0.2))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if message.isFromUser {
                Spacer(minLength: 50)
            }
        }
    }
}

struct SupportChatInputArea: View {
    @Binding var messageText: String
    @Binding var showingImagePicker: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: AppConstants.Spacing.medium) {
                Button(action: { showingImagePicker = true }) {
                    Image(systemName: "paperclip")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                TextField("Напишите сообщение...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)
                
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .secondary : AppConstants.Colors.primary)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
    }
}

// MARK: - Support Tickets

struct SupportTicketsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingNewTicket = false
    
    private var userTickets: [SupportTicket] {
        dataManager.supportTicketsState.items.filter { $0.userId == authViewModel.currentUser?.id }
    }
    
    var body: some View {
        Group {
            if dataManager.supportTicketsState.isLoading {
                ProgressView("Загрузка обращений...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if userTickets.isEmpty {
                EmptyTicketsView(showingNewTicket: $showingNewTicket)
            } else {
                List {
                    ForEach(userTickets.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { ticket in
                        NavigationLink(destination: SupportTicketDetailView(ticket: ticket)) {
                            SupportTicketRow(ticket: ticket)
                        }
                    }
                }
            }
        }
        .navigationTitle("Мои обращения")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Новое") {
                    showingNewTicket = true
                }
                .foregroundColor(AppConstants.Colors.primary)
            }
        }
        .sheet(isPresented: $showingNewTicket) {
            NewSupportTicketView()
        }
        .task {
            await dataManager.loadDataType(.supportTickets)
        }
    }
}

struct EmptyTicketsView: View {
    @Binding var showingNewTicket: Bool
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("У вас нет обращений")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Создайте обращение, если у вас есть вопросы")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Создать обращение") {
                showingNewTicket = true
            }
            .padding()
            .background(AppConstants.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}

struct SupportTicketRow: View {
    let ticket: SupportTicket
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            HStack {
                Text(ticket.subject)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                StatusBadge(status: ticket.status)
            }
            
            HStack {
                PriorityBadge(priority: ticket.priority)
                
                Spacer()
                
                Text(ticket.createdAt.formattedDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let lastMessage = ticket.messages.last {
                Text(lastMessage.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: SupportTicket.TicketStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(4)
    }
}

struct PriorityBadge: View {
    let priority: SupportTicket.Priority
    
    var body: some View {
        Text("Приоритет: \(priority.displayName)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct SupportTicketDetailView: View {
    let ticket: SupportTicket
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.medium) {
                ForEach(ticket.messages, id: \.id) { message in
                    TicketMessageView(message: message)
                }
            }
            .padding()
        }
        .navigationTitle(ticket.subject)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TicketMessageView: View {
    let message: SupportMessage
    
    var body: some View {
        HStack {
            if message.senderRole == .customer {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.senderRole == .customer ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, AppConstants.Spacing.medium)
                    .padding(.vertical, 10)
                    .background(message.senderRole == .customer ? AppConstants.Colors.primary : Color.secondary.opacity(0.2))
                    .foregroundColor(message.senderRole == .customer ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if message.senderRole != .customer {
                Spacer(minLength: 50)
            }
        }
    }
}

struct NewSupportTicketView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var priority = SupportTicket.Priority.medium
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Spacing.large) {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                    Text("Тема обращения")
                        .font(.headline)
                    
                    TextField("Опишите проблему кратко", text: $subject)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                    Text("Приоритет")
                        .font(.headline)
                    
                    Picker("Приоритет", selection: $priority) {
                        ForEach(SupportTicket.Priority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                    Text("Сообщение")
                        .font(.headline)
                    
                    TextEditor(text: $message)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Button("Отправить обращение") {
                    createTicket()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSubmit ? AppConstants.Colors.primary : Color.secondary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!canSubmit)
            }
            .padding()
            .navigationTitle("Новое обращение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        !subject.isEmpty && !message.isEmpty
    }
    
    private func createTicket() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        let firstMessage = SupportMessage(
            id: UUID().uuidString,
            content: message,
            senderId: userId,
            senderRole: .customer,
            timestamp: Date(),
            attachments: []
        )
        
        let newTicket = SupportTicket(
            id: UUID().uuidString,
            userId: userId,
            subject: subject,
            messages: [firstMessage],
            status: .open,
            createdAt: Date(),
            updatedAt: Date(),
            priority: priority
        )
        
        dataManager.supportTicketsState.addItem(newTicket)
        dismiss()
    }
}

// MARK: - FAQ

struct FAQView: View {
    private let faqs = [
        FAQ(question: "Как получить баллы?", answer: "Сканируйте QR-коды на упаковках автозапчастей с помощью встроенного сканера в приложении."),
        FAQ(question: "Как обменять баллы на товары?", answer: "Перейдите в раздел 'Каталог', выберите товар и нажмите 'Обменять'. Убедитесь, что у вас достаточно баллов."),
        FAQ(question: "Как запросить цену на автомобиль?", answer: "В разделе 'Автотиндер' найдите понравившийся автомобиль и нажмите кнопку с вопросительным знаком или 'Запросить цену'."),
        FAQ(question: "Как связаться с поддержкой?", answer: "Используйте чат поддержки в разделе 'Профиль' или создайте обращение в 'Мои обращения'."),
        FAQ(question: "Сгорают ли баллы?", answer: "Нет, баллы не имеют срока действия и остаются на вашем счету неограниченное время."),
        FAQ(question: "Как участвовать в розыгрышах?", answer: "В разделе 'Главная' или 'Розыгрыши' найдите активные лотереи. Убедитесь, что у вас достаточно баллов для участия."),
        FAQ(question: "Можно ли отменить заказ?", answer: "Заказы можно отменить только в статусе 'Ожидает подтверждения'. Обратитесь в поддержку для отмены."),
        FAQ(question: "Как изменить личные данные?", answer: "В разделе 'Профиль' нажмите на иконку редактирования рядом с вашими данными.")
    ]
    
    var body: some View {
        List {
            ForEach(faqs, id: \.question) { faq in
                FAQRow(faq: faq)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQ {
    let question: String
    let answer: String
}

struct FAQRow: View {
    let faq: FAQ
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(faq.question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(faq.answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SupportChatView()
            .environmentObject(AuthViewModel())
            .environmentObject(DataManager())
    }
}
