BidNest

BidNest is a lightweight auction platform built with Ruby on Rails, allowing users to create, manage, and participate in auctions. The application supports real-time bidding, automated auction ending, and an elegant, responsive UI for both bidders and sellers.

Features
Core Functionality

Auction Management: Users can create, edit, publish, and delete auctions.

Draft & Published Auctions: Draft auctions can be saved and published later. Published auctions are visible to all bidders.

Bidding System:

Users can place bids on active auctions.

Only the leading bid is automatically updated to beat a challenger.

Users can view their bids in a personalized dashboard.

Auction End Automation:

Auctions automatically end at their ends_at time.

Background workers handle auction finalization efficiently with Sidekiq.

User Authentication: Implemented via Devise for secure login/logout and account management.

Responsive UI:

Custom-designed cards and buttons for auctions and bids.

Elegant blue-and-white theme for a clean, professional look.

Error Handling: Proper validation for bids, auctions, and user inputs. Graceful handling of exceptions.

Dashboard: View draft and published auctions

Auction Card: Shows title, price, description, and action buttons

User Bids: Displays bids placed by the logged-in user

Technology Stack

Backend: Ruby 3.1.3, Ruby on Rails 7

Frontend: Haml, ERB, CSS

Database: MySQL

Background Jobs: Sidekiq (for auction autobidding and auto-ending)

Authentication: Devise gem

Testing: RSpec (optional for unit and integration tests)

Version Control: Git & GitHub


Installation


Clone the repository:

git clone https://github.com/Ramani-priya/auction-app.git
cd auction-app


Install dependencies:

install Ruby v 3.1.3, mysql, redis, bundler

Minimal required gems for submission:

rails, mysql2, puma

devise (authentication)

sidekiq, sidekiq-scheduler (background jobs)

haml-rails (views)

rspec-rails, factory_bot_rails, faker (tests)

rubocop, rubocop-rails, rubocop-performance


Install the gem dependencies

bundle install


Set up the database:

rails db:create db:migrate db:seed


Start Sidekiq for background jobs:

bundle exec sidekiq


Run the Rails server:

rails server


Visit http://localhost:3000 in your browser.

Usage

Sign up or log in as a user.

Navigate to Manage Auctions to create new auctions.

Draft auctions can be published later.

View all published auctions to place bids.

Monitor your active bids in the My Bids section.

Auctions automatically end, and the highest bidder wins if the price meets the minimum selling price.

Cron Jobs & Background Workers

AutoBidJob: Run and creates bids on behalf of users who have chosen auto bid for auctions
EndAuctionsJob: Ends auctions that have reached ends_at, marking winners and finalizing bids.
Scheduling: Jobs can be scheduled via sidekiq-scheduler or cron for periodic execution.

Testing

Unit and integration tests are written with RSpec.

Example command:

bundle exec rspec filepath


Test coverage includes:

Auction creation, publishing, and deletion

Bidding workflow

Background job execution

Authentication and user-specific views

Code Quality

RuboCop is configured to enforce consistent style and Rails best practices.

Auto-correctable formatting issues can be fixed using:

bundle exec rubocop -A

Contributing

Fork the repository.

Create a feature branch:

git checkout -b feature/your-feature


Make your changes and commit them with clear messages:

git commit -m "Add feature X"


Push to your fork and create a Pull Request.

License

This project is licensed under the MIT License. See the LICENSE
 file for details.
