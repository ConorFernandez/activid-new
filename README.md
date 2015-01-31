## Activid

Activid is a company that connects freelance video editors with customers who need their services. The videos that customers need edited are things like vacation videos, sports reels, Kickstarter pitches, etc. Pricing for the projects is based on length of uploaded customer video, category, desired length of the final video, and a few other factors.

### Zencoder

We use [Zencoder](http://zencoder.com/) to process all uploaded video files. For customer uploads, this allows us to determine how long the videos are (so that we know how much to quote them for their project), and for editor uploads it allows us to watermark a preview version of the video which the customer can preview before paying for the project. For customer [DropBox uploads](https://www.dropbox.com/developers/dropins/chooser/js), Zencoder also handles transfering the video file from the user's DropBox account to Activid's S3 account.

### Project Flow

When a user comes to Activid for the first time, they start by creating a project in a multi-step form. The second step allows the user to upload videos from their computer or DropBox account. On the final step, a signup modal forces the user to create an account before continuing to the checkout page. It is only possible to complete the checkout page once all the uploaded videos have been processed by Zencoder.

After the user submits a project, it goes into a queue of projects that are waiting for editors. Editors can log in to Activid, view this queue, and claim projects that they want to work on.

The editor has a certain number of days to deliver the first "cut" for a project, depending on what the user selected at project creation. After posting a cut, the user can view a watermarked version of it, and choose to approve it or ask for another revision. Once a user approve a cut, their project is completed and their card is charged.

If a cut is posted and a user does not approve it after two weeks, it will be approved automatically. The user will get a warning about this after one week.

After a project has been completed, a nightly rake task will pick it up and send the editor their cut of the revenue via a [Stripe transfer](https://stripe.com/docs/tutorials/sending-transfers).

### Direct Upload

In addition to linking to files in DropBox, users can upload files from their local computer. Since we don't want to tie up server threads or rely on Heroku's storage for these files, uploads are sent directly to the Activid S3 account using the [jQuery file upload](https://github.com/blueimp/jQuery-File-Upload) library. All the code for this integration is in `app/assets/javascripts/direct_upload.js.coffee`.

### Clock.rb

This project uses a [clock process](https://devcenter.heroku.com/articles/scheduled-jobs-custom-clock-processes) for scheduling background jobs. This allows more control than Heroku's built-in scheduler. The jobs and their schedules are defined in `lib/clock.rb`.

### Config and Deployment

Activid is hosted on Heroku, so deployments are just a matter of pushing to the Heroku branch and and running any necessary migrations.

If you run the app locally with foreman (eg: `foreman start` or `foreman run rails c`), it will load the environment variables defined in `.env` (API keys, S3 bucket name, etc). If you need a list of these config keys and some sample values, check the staging app (`heroku config -a activid-stagingg`)
