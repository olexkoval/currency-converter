
# Currency Converter

Currency Converter is a simple, one-page iOS application that allows users to convert currencies using real-time exchange rates.

## Features
- **Currency Selection**: Users can select two currencies, one for the source and one for the target currency.
- **Amount Input**: Users can input the amount they wish to convert.
- **Automatic Conversion**: The app updates the converted amount automatically whenever the source currency, target currency, or input amount changes. It also refreshes periodically every 10 seconds.
- **Real-Time Exchange Rates**: Conversion rates are fetched from a real-time API.

## Requirements
- **Xcode Version**: 15.4
- **Swift Version**: 5
- **iOS Deployment Target**: 14.0

## Setup Instructions
Follow these steps to set up and run the Currency Converter project:

1. **Clone the Repository**:
   ```bash
   git clone git@github.com:olexkoval/currency-converter.git
   cd <project_directory>
   ```

2. **Open the Project**:
   - Open `CurrencyConverter.xcodeproj` in Xcode.

3. **Install Dependencies**:
   - The project uses `Swinject` for dependency injection via Swift Package Manager (SPM).
   - Ensure dependencies are resolved automatically in Xcode by navigating to `File > Packages > Resolve Package Versions`.

4. **Configure Supported Currencies**:
   - Open the `Currency.swift` file.
   - Specify the list of supported currency ISO codes in the provided array if needed. If not specified, the system's foundation currency list will be used.

5. **Run the App**:
   - Select an iOS simulator.
   - Press `Command + R` to build and run the project.

## Known Issues
- Occasionally, Xcode logs the following message during runtime while keyaboard appearance:

-[RTIInputSystemClient remoteTextInputSessionWithID:performInputOperation:]  perform input operation requires a valid sessionID. inputModality = Keyboard, inputOperation = <null selector>, customInfoType = UIEmojiSearchOperations

  This issue does not affect the app's functionality and appears to be related to an internal Xcode or iOS framework behavior. A resolution is yet to be identified.

## Troubleshooting
- Ensure you are using the correct Xcode version (15.4) and Swift version (5).
- Check that the `Swinject` package is properly installed and integrated.

## License
This project is provided "as-is" for evaluation and testing purposes. Contact the author for further use.

## Contact
For support or inquiries, please contact [shurik.koval@gmail.com].
