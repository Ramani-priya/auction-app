# BidNest

**BidNest** is a lightweight auction platform built with Ruby on Rails. It allows users to create, manage, and participate in auctions with real-time bidding, automated auction ending, and a clean, responsive UI.

---

## Features

### Core Functionality
- **Auction Management:** Users can create, edit, publish, and delete auctions.
- **Draft & Published Auctions:** Draft auctions can be saved and published later. Published auctions are visible to all bidders.

### Bidding System
- Users can place bids on active auctions.
- Only the leading bid is automatically updated to beat a challenger.
- Users can view their bids in a personalized dashboard.

### Auction End Automation
- Auctions automatically end at their `ends_at` time.
- Background workers handle auction finalization efficiently with Sidekiq.

### User Authentication
- Implemented via `devise` for secure login/logout and account management.

### Responsive UI
- Custom-designed cards and buttons for auctions and bids.
- Elegant blue-and-white theme for a clean, professional look.

### Error Handling
- Proper validation for bids, auctions, and user inputs.
- Graceful handling of exceptions.

### Dashboard
- View draft and published auctions.
- Auction cards show title, price, description, and actions.
- User bids are displayed in a dedicated section.

---

## Key Assumptions & Design Decisions

### Data Immutability
- Auctions and bids are immutable to prevent race conditions. Once placed, they cannot be edited or deleted.
- Sellers can edit auctions while in draft state. Once published, auctions become immutable.

### Concurrency and Race Conditions
- **Simultaneous Bids:** Optimistic locking is used. If two bids are placed at the same time, one transaction may fail and require a retry.
- **Auto-Bid Job Queue:** Auto-bids are processed in FIFO order via Sidekiq for fairness and predictability.

#### Handling Edge Cases
- Auto-bidders with the same `max_bid_price` are resolved by tie-breaking based on the earliest bid creation time.

---

## Auto-Bidding Logic

- **Winning Bidder:** The highest `max_bid_price` wins. Ties are resolved by bid creation time.
- **Winning Price:** The final price is the minimum of:
  1. The highest bidder’s `max_bid_price`.
  2. The second-highest bidder’s `max_bid_price` plus the auction’s `minimum_increment`.
- **Handling Ties:** When multiple bidders have the same `max_bid_price`, the first bidder wins at the price of the current highest bid plus the minimum increment.

This ensures bidders never pay more than necessary to win.

---

## Usage

1. Sign up or log in as a user.
2. Use the dashboard to navigate **Sell / Buy / My Bids**.
3. In **Sell (Manage Auctions)**, create new auctions or publish drafts.
4. View all published auctions in **Buy**, and place bids.
5. Enable autobid to automatically outbid challengers within your max price.
6. Track all active bids in **My Bids**.
7. Auctions automatically end at `ends_at` and winners are chosen based on the final price.

### Screenshots on usage

<img width="1393" height="717" alt="Screenshot 2025-09-11 at 12 44 10 AM" src="https://github.com/user-attachments/assets/b5a6460d-904d-45f3-9731-cad85b93fba5" />
<img width="1378" height="519" alt="Screenshot 2025-09-11 at 12 45 09 AM" src="https://github.com/user-attachments/assets/7bd52af0-c75c-4559-8573-9aa0e0347b7a" />
<img width="1382" height="715" alt="Screenshot 2025-09-11 at 12 47 02 AM" src="https://github.com/user-attachments/assets/7bbfe0bb-ac14-4554-a96b-5b4955fa6595" />
<img width="1426" height="715" alt="Screenshot 2025-09-11 at 12 46 31 AM" src="https://github.com/user-attachments/assets/47a3741d-6359-44a8-a922-68d860de4ef4" />
<img width="1388" height="608" alt="Screenshot 2025-09-11 at 12 47 18 AM" src="https://github.com/user-attachments/assets/1372ac6d-1df0-475d-994d-b4e686bf0247" />
<img width="1348" height="379" alt="Screenshot 2025-09-11 at 12 47 31 AM" src="https://github.com/user-attachments/assets/c0fc3a2c-451f-49e4-8926-c0ecedba5e16" />
<img width="1341" height="519" alt="Screenshot 2025-09-11 at 12 47 40 AM" src="https://github.com/user-attachments/assets/18d73e40-d2e7-4e62-a362-a569b429c45d" />
<img width="1366" height="612" alt="Screenshot 2025-09-11 at 12 48 27 AM" src="https://github.com/user-attachments/assets/32a995ec-0841-4a13-ac94-35b20cf67477" />

## emails after auction has ended
<img width="1099" height="344" alt="Screenshot 2025-09-11 at 12 24 40 AM" src="https://github.com/user-attachments/assets/346ee485-b0c5-44c3-ae99-9cbf73d0d33f" />
<img width="1211" height="416" alt="Screenshot 2025-09-11 at 12 25 29 AM" src="https://github.com/user-attachments/assets/3af05337-4c38-4f5a-9314-41270c791238" />
<img width="1217" height="357" alt="Screenshot 2025-09-11 at 12 25 42 AM" src="https://github.com/user-attachments/assets/4fafd834-3f20-4190-85d6-cd74483b7e65" />

---

## External Integrations

- Webhooks are configurable in `webhooks.yml`.

<img width="1322" height="653" alt="Screenshot 2025-09-11 at 12 24 57 AM" src="https://github.com/user-attachments/assets/0574cab7-8949-4418-9a9d-cb6439226d25" />

---

## Cron Jobs & Background Workers

- **AutoBidJob:** Creates bids for users with autobid enabled.
- **EndAuctionsJob:** Ends auctions that have reached their end time.
- Jobs are scheduled via `sidekiq-scheduler` or cron.

---

## Testing

Tests are written using `rspec-rails`.

```sh
bundle exec rspec filepath
```

## Test Coverage Includes:

✅ Auction creation, publishing, and deletion

✅ Bidding workflow including bid creation and autobid processes

✅ View specs, helper specs, and model validations

✅ Service objects and notifier functionalities

✅ Background job execution

✅ Authentication and user-specific views

<img width="1066" height="139" alt="Screenshot 2025-09-11 at 12 27 18 AM" src="https://github.com/user-attachments/assets/51845441-d085-4f85-ab7b-1f2332874af5" />


## Code Quality

**RuboCop** is configured for code consistency and best practices.

```sh
bundle exec rubocop -A
```

## Tech Stack & Dependencies

**Primary Language/Framework:**
- Ruby on Rails (Ruby 3.1.3, Rails ~> 7.0.8)

**Database:**
- MySQL

**Key Ruby Gems:**
- `devise` (authentication)
- `haml-rails`, `importmap-rails`, `jbuilder`, `kaminari`, `mysql2`, `puma`, `rails`, `redis`, `sassc-rails`, `sidekiq`, `sidekiq-cron`, `tzinfo-data`
- For development/test: `database_cleaner-active_record`, `debug`, `factory_bot_rails`, `pry`, `pry-byebug`, `pry-rails`, `rspec-rails`, `rubocop`, `rubocop-capybara`, `rubocop-factory_bot`, `rubocop-performance`, `rubocop-rails`, `rubocop-rspec`, `web-console`
- For test: `capybara`, `selenium-webdriver`, `shoulda-matchers`, `webmock`

**Tools/Tech:**
- Redis (for background jobs/sidekiq)
- Sidekiq/Sidekiq-cron (background job processing)
- Puma (web server)
- Haml (templating)
- Stimulus/Turbo (frontend interactivity)

## Setup Steps to Run Locally

1. **Clone the repository:**
   ```sh
   git clone https://github.com/Ramani-priya/auction-app.git
   cd auction-app
   ```
2. **Install Ruby (3.1.3) and Bundler:**
   - Use a Ruby version manager like `rbenv` or `rvm` to install Ruby 3.1.3.
   - Install Bundler:
     ```sh
     gem install bundler
     ```
3. **Install MySQL and Redis:**
   - Install MySQL (make sure the server is running).
   - Install Redis (make sure the server is running).

4. **Install dependencies:**
   ```sh
   bundle install
   ```
5. **Set up the database:**
   - Create and migrate the database:
     ```sh
     rails db:create
     rails db:migrate
     ```
6. **(Optional) Seed the database:**
   ```sh
   rails db:seed
   ```
7. **Start Sidekiq (in a separate terminal):**
   ```sh
   bundle exec sidekiq
   ```
8. **Start the Rails server:**
   ```sh
   rails server
   ```
9. **Visit the app in your browser:**
   - Open `http://localhost:3000`

**Note:** Make sure you have the necessary MySQL and Redis development headers installed for building native extensions. If you encounter any errors, check for missing libraries or OS-specific dependencies typically required for compiling some Ruby gems.

## Version Control: Git & GitHub

## Contributing
 - Fork the repository.
 - Create a feature branch:
 ```sh
 git checkout -b feature/your-feature
 ```
- Make your changes and commit them with clear messages:
```sh
git commit -m "Add feature X"
```
- Push to your fork and create a Pull Request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
