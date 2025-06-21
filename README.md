# Welcome to ScrollingLibrary

This Swift package provides an infinite and automatic scrolling view, along with a dot scrolling indicator.

# Scrolling view

At its core, it uses the new SwiftUI APIs introduced at WWDC 24 (ForEach and Group). Automatic scrolling is enabled through asynchronous behavior. The architecture follows the MVVM pattern, and both the model and the view model are tested using Swift Testing.

<img src="https://github.com/user-attachments/assets/256ff4a0-0227-46c2-b29e-ad3e6f651560" alt="ScrollingView" width="200"/>

To try this package, I recommend checking out my [ScrollingLibraryUITest](https://github.com/elf0-fr/ScrollingLibraryUITest) application. It’s designed to test the package’s UI using XCUITest.

# Dot indicator

<img src="https://github.com/user-attachments/assets/a3255b52-5afa-4db8-8ba4-30bd92e6bf08" alt="Dots indicator" width="200"/>

