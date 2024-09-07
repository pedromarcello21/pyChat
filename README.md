# pyChat

**pyChat** is a versatile bot assistant that leverages OpenAI's API and function calling capabilities to provide a wide range of personalized functionalities. With pyChat, you can effortlessly send emails, draft LinkedIn messages, open applications, find flights, show art from The Met, and much more. The application features a Flask backend and a SwiftUI frontend, offering an intuitive user interface and seamless API integrations.

## Features

- **Send Emails**: Compose and send emails directly through pyChat using your Gmail account.
- **Draft LinkedIn Messages**: Get AI-generated LinkedIn message drafts tailored to your needs.
- **Open Applications**: Command pyChat to open various applications on your device.
- **Find Flights**: Search for and display flight options based on your preferences.
- **Show Art from The Met**: Explore and view artworks from The Metropolitan Museum of Art.
- **And More**: pyChat is constantly expanding its capabilities with new features!

## Technology Stack

- **Backend**: Flask
- **Frontend**: SwiftUI
- **AI Integration**: OpenAI API

## Getting Started

### Prerequisites

- **Python 3.8+**
- **Pipenv**: For managing dependencies and virtual environments.
- **Xcode**: Required for interacting with the SwiftUI frontend.
- **Postman**: Optional tool for making API calls if you do not have Xcode.

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/your-username/pyChat.git
   cd pyChat
   ```

2. **Set Up the Environment:**

   Create a `.env` file in the root directory of the project with the following variables:

   ```env
   SECRET_KEY=**ask me for this at vincentypedro@gmail.com**
   OPENAI_API_KEY=your_openai_api_key
   APP_PASSWORD=your_gmail_app_password
   ```

3. **Install Dependencies:**

   Use `pipenv` to install all required libraries:

   ```bash
   pipenv install
   ```

4. **Activate the Virtual Environment:**

   ```bash
   pipenv shell
   ```

5. **Run the Flask Backend:**

   ```bash
   flask run
   ```

### Interacting with the UI

- **Using Xcode**: Open the project in Xcode and run the SwiftUI frontend to interact with pyChat.
- **Using Postman**: If you don't have Xcode, you can use Postman to make API calls directly to the Flask backend.

## Usage

Once everything is set up, you can start using pyChat's features via the SwiftUI interface or by sending API requests. The bot will assist you with various tasks, offering AI-powered solutions and personalized experiences.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

---

**Note**: Ensure that you keep your `.env` file secure and do not share your secret keys or passwords publicly.
