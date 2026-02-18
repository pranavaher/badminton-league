# Badminton League - Auto-Decide Feature Documentation

## Overview

The application now supports **automatic match result assignment** using Sidekiq background jobs. When creating a match, users can choose to enable "auto-decide" mode, which will automatically assign a winner at the scheduled match time.

## Features

### Manual Mode (Default)

- User creates a match with a future scheduled time
- After the scheduled time has passed, manual "Mark A as winner" / "Mark B as winner" buttons appear
- User manually selects the winner
- Badge shows "Yet to start" until scheduled time passes

### Auto-Decide Mode

- User checks "Auto-decide winner at scheduled time?" checkbox when creating a match
- A Sidekiq job is automatically scheduled to run at the `scheduled_at` time
- Job randomly selects one of the two players as the winner
- Job automatically calls the match's `decide_winner!` method
- Badge shows "Auto-decide pending" for matches awaiting automatic decision
- Once the winner is assigned (either automatically or manually), it displays in the results column

## Configuration

### Dependencies Added

- **Sidekiq 8.1.1**: Background job processing library
- **Redis 5.4.1**: In-memory data store for job queue

### Environment Setup

#### Development

1. Ensure Redis is running:

   ```bash
   redis-server
   ```

2. Run both Rails server and Sidekiq worker:

   ```bash
   # Terminal 1: Rails server
   bundle exec rails s -p 3000

   # Terminal 2: Sidekiq worker
   bundle exec sidekiq -c 5 -v
   ```

   Or use `foreman` with the provided Procfile.dev:

   ```bash
   gem install foreman
   foreman start -f Procfile.dev
   ```

#### Production

- Redis should be running on a production server (e.g., configured via REDIS_URL environment variable)
- Sidekiq worker processes should be deployed alongside the Rails app

### Configuration Files

- **config/sidekiq.yml**: Sidekiq concurrency, queue, and retry settings
- **config/initializers/sidekiq.rb**: Sidekiq client/server configuration with Redis connection

## Database Schema

### Matches Table Changes

New columns added via migration `20260218140002_add_auto_decide_to_matches.rb`:

- `auto_decide` (boolean, default: false): Whether to automatically assign a winner
- `job_id` (string): Stores the Sidekiq job ID for future cancellation

## Code Changes

### Model: Match (`app/models/match.rb`)

- **Validation**: `auto_decide_requires_future_scheduled_at` - ensures auto_decide is only set for future-scheduled matches
- **Callback**: `after_create :schedule_auto_decide_job` - schedules job when match is created
- **Method**: `schedule_auto_decide_job` - schedules AutoDecideWinnerJob with `wait_until: scheduled_at`
- **Method**: `cancel_auto_decide_job` - cancels scheduled job if needed (called on delete/update)

### Job: AutoDecideWinnerJob (`app/jobs/auto_decide_winner_job.rb`)

- Sidekiq job that runs at the scheduled time
- Randomly selects between player_a and player_b as winner
- Calls `match.decide_winner!` to assign winner and loser
- Safeguards: returns early if match already has winner or auto_decide is false

### Controller: MatchesController (`app/controllers/matches_controller.rb`)

- **Permitted params**: Now includes `:auto_decide`
- **Update action**: Cancels job if auto_decide is toggled off
- **Destroy action**: Cancels job before destroying match

### View: Matches Index (`app/views/matches/index.html.erb`)

- **Conditional buttons**: Manual "Mark A/B as winner" buttons only show for matches with `auto_decide: false`
- **Status badge**: Shows "Auto-decide pending" for scheduled auto-decide matches

### View: Match Form (`app/views/matches/_form.html.erb`)

- **Checkbox**: "Auto-decide winner at scheduled time?" - allows users to enable auto-decide mode

## Usage Example

1. **Create a match with auto-decide enabled:**
   - Go to "New Match"
   - Select Player A: John Doe
   - Select Player B: Jane Smith
   - Select Venue: India
   - Set Scheduled At: 2025-02-20 at 15:30
   - Check "Auto-decide winner at scheduled time?"
   - Click Save

2. **Result:**
   - Match is saved with `auto_decide: true`
   - Sidekiq job is scheduled to run at 2025-02-20 15:30 (IST)
   - Match appears in list with "Auto-decide pending" badge
   - At 15:30 IST, job automatically runs and randomly assigns winner
   - Next page load shows winner assigned in results column

## Testing

### Manual Testing Steps

1. Create match with auto_decide: true and future scheduled_at
2. Verify "Auto-decide pending" badge shows in match list
3. Create match with auto_decide: false
4. Verify "Mark A/B as winner" buttons appear when scheduled time passes
5. Edit auto_decide match to turn off auto_decide - job should be cancelled
6. Delete auto_decide match - job should be cancelled

### Verifying Sidekiq Execution

- Check Sidekiq console: `bundle exec sidekiq -c 5 -v`
- Look for job execution logs showing "AutoDecideWinnerJob" processing
- Verify "winner_id" and "loser_id" are set in matches table after scheduled time

## Important Notes

### Timezone Handling

- All times use IST (Asia/Kolkata timezone) per `config.time_zone`
- Job scheduling uses `wait_until: scheduled_at` which respects application timezone

### Job Persistence

- Job IDs stored in `match.job_id` for future management
- If match is updated/deleted, job is cancelled to prevent orphaned jobs

### Validation

- auto_decide cannot be true unless scheduled_at is in the future
- Will show validation error: "Auto-decide requires scheduled_at to be in the future"

### Idempotency

- AutoDecideWinnerJob checks if match already has winner before deciding
- Safe to retry if job execution fails

## Future Enhancements

Potential improvements:

1. Add UI to preview which job is scheduled
2. Add ability to manually cancel scheduled jobs from UI
3. Add job execution history/logs to match details
4. Add option to re-run decision if result was incorrect
5. Add webhook notifications when auto-decide completes
6. Add different auto-decide algorithms (not just random selection)
