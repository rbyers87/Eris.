import SwiftUI
import Combine

@MainActor
class ChatScrollManager: ObservableObject {
    @Published var shouldScrollToBottom = false
    @Published var contentHeight: CGFloat = 0
    @Published var showScrollToBottomButton = false
    @Published var isAtBottom = true
    
    private var cancellables = Set<AnyCancellable>()
    private var scrollProxy: ScrollViewProxy?
    private var isUserScrolling = false
    private var lastMessageCount = 0
    private var pendingScrolls = 0
    
    init() {
        setupContentHeightObserver()
        setupKeyboardObservers()
    }
    
    func setProxy(_ proxy: ScrollViewProxy) {
        self.scrollProxy = proxy
    }
    
    // MARK: - Content Height Observer
    
    private func setupContentHeightObserver() {
        $contentHeight
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.pendingScrolls ?? 0 > 0 {
                    self?.pendingScrolls = 0
                    self?.scrollToBottom()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                // Always scroll to bottom when keyboard appears if we were at bottom
                if self?.isAtBottom == true {
                    // Use the keyboard animation duration for smooth transition
                    withAnimation(.easeOut(duration: duration)) {
                        self?.scrollProxy?.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Scroll Actions
    
    func scrollToBottom(animated: Bool = true) {
        guard let proxy = scrollProxy else { return }
        
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
    
    func scrollToBottomSmooth() {
        // Small delay to ensure layout is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    func handleNewMessage() {
        // Mark that we have a pending scroll
        pendingScrolls += 1
        // The actual scroll will happen when content height changes
    }
    
    func handleTypingStarted() {
        // Wait for typing indicator to appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    func handleContentUpdate() {
        // For streaming content, scroll smoothly
        if !isUserScrolling {
            scrollToBottom(animated: true)
        }
    }
    
    // MARK: - User Interaction
    
    func userDidScroll() {
        isUserScrolling = true
        
        // Reset after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isUserScrolling = false
        }
    }
    
    func isNearBottom(geometry: GeometryProxy, contentHeight: CGFloat) -> Bool {
        let scrollOffset = geometry.frame(in: .global).minY
        let contentBottom = contentHeight - geometry.size.height
        return scrollOffset < -contentBottom + 100 // Within 100 points of bottom
    }
}