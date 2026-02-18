# Badminton League Management System

A Rails-based web application for managing badminton league tournaments. Users can create and manage players, record match results, track player rankings, and view comprehensive statistics.

## Features

- **Player Management**: Add, edit, delete, and view players with country association
- **Match Tracking**: Record match results with scheduled dates/venues
- **Winner Assignment**: Decide match winners only after scheduled time has passed
- **Leaderboard**: Rankings based on total wins with win rate calculations
- **Performance Stats**: Per-player match history and statistics
- **Venue Statistics**: Matches per venue (country) and wins/losses by player country
- **Pagination**: All list views paginated for better performance
- **Authentication**: Devise-based user authentication for secure access

## Tech Stack

- **Framework**: Rails 8.1.2
- **Database**: SQLite3
- **Frontend**: Bootstrap 5, Stimulus.js, Turbo
- **Authentication**: Devise
- **Pagination**: Kaminari
- **Ruby Version**: 3.3.x

## Database Models & Associations

### User
- Devise authentication model
- Relations: None specific to badminton logic

### Country
- `name` (String, unique): Country name
- Associations:
  - `has_many :players` (dependent: :nullify)
  - `has_many :matches, foreign_key: 'venue_id'` (dependent: :nullify)

### Player
- `first_name` (String): First name (required)
- `last_name` (String): Last name (required)
- `country_id` (FK): Reference to Country (required)
- Associations:
  - `belongs_to :country` (required: true)
  - `has_many :wins` (class_name: 'Match', foreign_key: 'winner_id', dependent: :nullify)
  - `has_many :losses` (class_name: 'Match', foreign_key: 'loser_id', dependent: :nullify)
- Methods:
  - `name`: Returns formatted "FirstName LastName"
  - `wins_count`: Returns number of wins
  - `losses_count`: Returns number of losses
  - `rank_by_wins`: Scope ordering players by wins DESC, last_name ASC

### Match
- `name` (String): Match name/identifier (optional)
- `player_a_id` (FK): Reference to Player A (required)
- `player_b_id` (FK): Reference to Player B (required)
- `venue_id` (FK): Reference to Country for venue (required)
- `scheduled_at` (DateTime): Match scheduled date/time (required)
- `winner_id` (FK): Reference to Player winner (optional)
- `loser_id` (FK): Reference to Player loser (optional)
- `created_at` / `updated_at` (DateTime): Timestamps
- Associations:
  - `belongs_to :player_a` (class_name: 'Player')
  - `belongs_to :player_b` (class_name: 'Player')
  - `belongs_to :venue` (class_name: 'Country', optional: false)
  - `belongs_to :winner` (class_name: 'Player', optional: true)
  - `belongs_to :loser` (class_name: 'Player', optional: true)
- Methods:
  - `scheduled_in_past?`: Returns true if scheduled_at < current time
  - `can_decide_winner?`: Returns true if match is scheduled in the past
  - `decide_winner!(choice)`: Assigns winner (choice: 'a', 'b', or player_id)

## Validations & Restrictions

### Player
- `first_name` and `last_name` presence required
- `country_id` presence required

### Match
- `player_a` and `player_b` presence required
- `venue` presence required
- `player_a` and `player_b` must be different (custom validation)
- `scheduled_at` must be in the future (custom validation)
- Cannot edit/update match if winner is already assigned
- Cannot decide winner if match is not scheduled in the past (backend + UI check)
- `decide_winner!` uses `update_columns` to bypass regular validations

### Timezone
- Application timezone set to `Asia/Kolkata` (IST)
- All time comparisons use application timezone

## Routes

### Devise Routes
```
POST   /users/sign_in              devise/sessions#create
GET    /users/sign_out             devise/sessions#destroy
POST   /users/sign_up              devise/registrations#create
GET    /users/edit                 devise/registrations#edit
PATCH  /users                      devise/registrations#update
```

### Players Routes
```
GET    /players                    players#index (paginated, 10 per page)
GET    /players/:id                players#show
GET    /players/:id/stats          players#stats (performance stats)
GET    /players/new                players#new
POST   /players                    players#create
GET    /players/:id/edit           players#edit
PATCH  /players/:id                players#update
DELETE /players/:id                players#destroy
```

### Matches Routes
```
GET    /matches                    matches#index (paginated, 10 per page)
GET    /matches/:id                matches#show
GET    /matches/new                matches#new
POST   /matches                    matches#create
GET    /matches/:id/edit           matches#edit
PATCH  /matches/:id                matches#update
DELETE /matches/:id                matches#destroy
POST   /matches/:id/decide         matches#decide (decide winner)
```

### Home Routes
```
GET    /                           home#index (admin dashboard)
GET    /leaderboard                home#leaderboard (paginated, 10 per page)
GET    /statistics                 home#statistics (venue & country stats)
GET    /admin                      home#index (alias for root)
GET    /health                     rails/health#show
```

## Statistics & Views

### Player Performance (`/players/:id/stats`)
- Total matches played
- Win count
- Loss count
- Win rate percentage
- Detailed match history with opponent, result, and venue

### Leaderboard (`/leaderboard`)
- Players ranked by total wins (descending)
- Shows: Rank, Player name, Country, Wins, Losses, Win rate %
- Paginated (10 per page)

### Site Statistics (`/statistics`)
- **Matches per Venue**: Shows count of matches played at each country/venue
- **Wins/Losses by Player Country**: Aggregates wins and losses for players from each country

## Setup & Installation

### Prerequisites
- Ruby 3.3.x
- Bundler
- SQLite3

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd badminton_league
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   bundle exec rails db:seed
   ```
   *(Seeds 20 countries: India, USA, UK, Canada, Australia, Japan, China, Germany, France, Brazil, Mexico, South Africa, Indonesia, Malaysia, Thailand, Singapore, Pakistan, Bangladesh, Sri Lanka, Nepal)*

4. **Create admin user** (via Rails console)
   ```bash
   bundle exec rails console
   User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123')
   exit
   ```

5. **Start the server**
   ```bash
   bundle exec rails server
   ```
   *(Available at http://localhost:3000)*

## Usage

### Creating a Player
1. Sign in as admin
2. Navigate to **Manage Players** → **New Player**
3. Enter first name, last name, and select country
4. Click **Create Player**

### Creating a Match
1. Navigate to **Manage Matches** → **New Match**
2. Enter match name (optional)
3. Select Player A and Player B (must be different)
4. Select Venue (country)
5. Set scheduled date/time (must be in the future)
6. Click **Create Match**

### Recording a Match Result
1. Navigate to **Manage Matches**
2. Once scheduled time has passed, "Mark A as winner" and "Mark B as winner" buttons appear
3. Click appropriate button to record winner
4. Edit button is hidden after result is recorded

### Viewing Statistics
1. **Player Performance**: Click "Performance" button on player show page (`/players/:id/stats`)
2. **Leaderboard**: Navigate to **Leaderboard** page for rankings
3. **Site Statistics**: Navigate to **Statistics** page for venue and country-level data

## Development Notes

- Pagination uses Kaminari gem (10 records per page by default)
- All lists support pagination via `page` query parameter
- Winner assignment bypasses validations to avoid scheduled_at blocking
- Devise handles authentication; all match/player actions require sign-in
- Bootstrap 5 CSS framework for responsive UI
- Turbo for fast page navigation

## File Structure

```
app/
  models/          # Country, Player, Match, User
  views/
    players/       # Players CRUD + stats
    matches/       # Matches CRUD + index
    home/          # Dashboard, leaderboard, statistics
    layouts/       # Application layout with navbar
  controllers/     # PlayersController, MatchesController, HomeController
config/
  routes.rb        # Route definitions
  application.rb   # Timezone configuration (Asia/Kolkata)
db/
  migrate/         # Database migrations
  seeds.rb         # Initial country seeding
  schema.rb        # Current schema
```

## Future Enhancements

- Match statistics by player pair (head-to-head)
- Tournament brackets and rounds
- CSV/PDF exports for stats
- Email notifications for match scheduling
- Admin dashboard with charts
- Match video/photo attachments
- Player profiles with bios/photos
