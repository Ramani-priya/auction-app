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

Key Assumptions & Design Decisions
Data Immutability
Auctions and Bids: For simplicity and to prevent race conditions, we've made auctions and bids immutable. They cannot be edited, deleted, or archived once they are placed.

Drafts: Sellers can edit auctions while they are in the draft state. Once an auction is published, it becomes immutable. This aligns with a clean and predictable data model.

Concurrency and Race Conditions
Simultaneous Bids: In the rare event that two bids are placed at the exact same time, optimistic locking is used to handle the conflict. One of the database transactions will fail with a StaleObjectError. The user will receive a 422 Unprocessable Entity response, preventing a bad state and requiring them to retry the bid.

Auto-Bid Job Queue: Auto-bid requests are processed by a Sidekiq job queue, which processes bids in a first-in, first-out (FIFO) order. This ensures fairness and predictable behavior. If a manual bid and an auto-bid attempt to update the auction simultaneously, the same optimistic locking mechanism will apply.

To account for the edge case where multiple auto-bidders have the same max_bid_price, you need to refine your auto-bidding algorithm's logic. This scenario requires a tie-breaker rule, which is typically based on the bid's creation time.

Here's the refined logic to handle this case, along with the updated determine_final_price method and its corresponding explanation for the README.

Auto-Bidding Logic
The core auto-bidding algorithm is designed to ensure the winning bidder always pays the lowest possible amount while outbidding the competition. The logic is based on three key factors: the highest max bid, the second-highest max bid, and the earliest creation time for ties.

Winning Bidder: The bidder with the highest max_bid_price wins the outbidding war. In case of a tie in max_bid_price, the bidder who placed their auto-bid earliest (first to bid) wins.

Winning Price: The final price is determined by the min() of two values:

The highest bidder's max_bid_price.

The second-highest bidder's max_bid_price plus the auction's minimum_increment.

Handling Ties: If multiple bidders have the same max_bid_price, the second-highest bid is effectively the current highest bid since they are tied. The new bid will be created by the first bidder to place their bid at the price of the current highest bid + the minimum increment.

This approach ensures that a bidder never pays more than necessary to win the auction.


Installation


Clone the repository:

git clone https://github.com/Ramani-priya/auction-app.git
cd auction-app


Install dependencies:

install Ruby v 3.1.3, mysql, redis, bundler

Minimal required gems for submission:

rails, mysql2, puma

devise user management, authentication

sidekiq, sidekiq-scheduler (background jobs)

haml-rails (views), letter_opener for local email testing, kaminari for pagination

rspec-rails, factory_bot_rails, faker (tests)

rubocop, rubocop-rails, rubocop-performance

webmock for external api mock tests

pry, pry-debug for debugging


Install the gem dependencies

bundle install


Set up the database:

rails db:create db:migrate (optional RAILS_ENV=test if setting up test db)


Start Sidekiq for background jobs:

bundle exec sidekiq


Run the Rails server:

rails server


Visit http://localhost:3000 in your browser.

Usage

Sign up or log in as a user.

The dashboard is a KISS principle based design, where we show sell / buy / my bids

Navigate to Sell space (Manage Auctions) to create new auctions, publish draft auctions, view the auctions currently published by you.

Draft auctions can be published later (publish button)

View all published and active auctions in the Buy space to place bids, users who are not sellers of the auction can place bid

You can choose to place autobids, so if a new buyer bids for a higher price an autobid is created on behalf of you with minimum increment as long as it is less than the max bid price you choose while placing a bid

Monitor all your active bids in the My Bids section.

Auctions automatically end, and the highest bidder wins if the price meets the minimum selling price.

Refer to below screenshots for a quick reference:
<img width="1393" height="717" alt="Screenshot 2025-09-11 at 12 44 10 AM" src="https://github.com/user-attachments/assets/b5a6460d-904d-45f3-9731-cad85b93fba5" />
<img width="1378" height="519" alt="Screenshot 2025-09-11 at 12 45 09 AM" src="https://github.com/user-attachments/assets/7bd52af0-c75c-4559-8573-9aa0e0347b7a" />
<img width="1382" height="715" alt="Screenshot 2025-09-11 at 12 47 02 AM" src="https://github.com/user-attachments/assets/7bbfe0bb-ac14-4554-a96b-5b4955fa6595" />
<img width="1426" height="715" alt="Screenshot 2025-09-11 at 12 46 31 AM" src="https://github.com/user-attachments/assets/47a3741d-6359-44a8-a922-68d860de4ef4" />
<img width="1388" height="608" alt="Screenshot 2025-09-11 at 12 47 18 AM" src="https://github.com/user-attachments/assets/1372ac6d-1df0-475d-994d-b4e686bf0247" />
<img width="1348" height="379" alt="Screenshot 2025-09-11 at 12 47 31 AM" src="https://github.com/user-attachments/assets/c0fc3a2c-451f-49e4-8926-c0ecedba5e16" />
<img width="1341" height="519" alt="Screenshot 2025-09-11 at 12 47 40 AM" src="https://github.com/user-attachments/assets/18d73e40-d2e7-4e62-a362-a569b429c45d" />
<img width="1366" height="612" alt="Screenshot 2025-09-11 at 12 48 27 AM" src="https://github.com/user-attachments/assets/32a995ec-0841-4a13-ac94-35b20cf67477" />

External intergrations and emails after auction has ended
<img width="1099" height="344" alt="Screenshot 2025-09-11 at 12 24 40 AM" src="https://github.com/user-attachments/assets/346ee485-b0c5-44c3-ae99-9cbf73d0d33f" />
<img width="1211" height="416" alt="Screenshot 2025-09-11 at 12 25 29 AM" src="https://github.com/user-attachments/assets/3af05337-4c38-4f5a-9314-41270c791238" />
<img width="1217" height="357" alt="Screenshot 2025-09-11 at 12 25 42 AM" src="https://github.com/user-attachments/assets/4fafd834-3f20-4190-85d6-cd74483b7e65" />
<img width="1322" height="653" alt="Screenshot 2025-09-11 at 12 24 57 AM" src="https://github.com/user-attachments/assets/0574cab7-8949-4418-9a9d-cb6439226d25" />



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

Bidding workflow including bid creation, autobid processes

View specs, helper specs, model specs for validations, callbacks

services specs, notifier specs

Background job execution

Authentication and user-specific views

<img width="1066" height="139" alt="Screenshot 2025-09-11 at 12 27 18 AM" src="https://github.com/user-attachments/assets/56e580f2-00aa-42fe-9973-318922552b67" />

Future Improvements

* Authorization gems
* Caching
* API and Webhooks extended configuration support
* Real-time Updates
* Payment and Settlement

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
