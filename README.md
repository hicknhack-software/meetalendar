# Meetalendar
TLDR: It allows the user to subscribe to meetup-groups events.

This gem prensents all the needed functionality to search for relevant groups on meetup, remember the chosen ones and offers a task that can be called regularely to transcribe the meetup-groups events to a google calendar.

## Usage
With the gem installed as described, it will have added itself to the admin interface. Navigte to it and find the two buttons that help you authorize the client with the meetup api and the google calendar api.
After authorization you can search for Meetup groups via the 'Add Groups' button. There you will be presented with a search mask formular with some default values for the 'find groups' Meetup Api call. (Check the [Meetup Api documentation](https://secure.meetup.com/meetup_api/console/?path=/find/groups) for more options.)

Then click search and you will be presented with the found groups for your search mask. (Or with groups in the area if you entered to little information and Meetup took your accounts location info to find groups near you.)
Then select the groups you want to "subscribe" to, enter the cities names that are "approved" and save them. With approved is meant, that only events of a selected group that are happening in an approved city are copied over into the google calendar. Thus avoiding "spamming", your google calendar with events that don't happen in the approved cities near you. (Most groups happen to meet in the same place each time while other groups events can happen to be spread out quite far.)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'meetalendar'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install meetalendar
```

Then run this generator that copies over setup, migrations and views:
```bash
$ rails generate comfy:meetalendar
```

And lastly run the migrations with:
```bash
$ rake db:migrate
```
Or sometimes:
```bash
$ bundle exec rake db:migrate
```

## Contributing
Just try your best. Maybe you can achieve one of these goals.

- [_] Wenn keine "approved cities" eingetragen sind, (oder wenn ein * oder ähnlich eingetragen ist) dann sollen alle Termine übertragen werden, egal in welcher Stadt sie stattfinden.
- [_] Wenn keine City in der Venue im Event eingetragen ist, dann soll dieser Termin erstmal mit übertragen werden, und sofern bei einer späteren Syncronisation festgestellt wird, dass dieses bereits im GCal eingetragene Event doch nicht hätte übertragen werden sollen, weil es in einer "nicht approvten" Stadt stattfindet, dann soll es wieder aus dem GCal gelöscht werden. (Aber nur für zukünftige Events, nicht rückwirkend auf jene, die schon stattgefunden haben.)
- [_] Wenn die "approvten cities" geändert werden, sollen ebenfalls die Termine, die noch in der Zukunft liegen entweder hinzugefügt oder gelöscht werden im GCal.

- Erweiterung der Admin-Ansicht, sodass auch einzelne bisher ausgeschlossene Events "von Hand" hinzugefügt werden können.
  - [_] Noch mal darüber sprechen, woher die Events kommen sollen? So eine Art von Suche bei der die bereits selektierten/gespeicherten Gruppen ihre nächsten (für 3 Monate) Events anzeigen und man diese trotz abweichender Städte in den GCal übertregen kann?

- [_] Kann man erkennen, ob ein Termin "von Hand" eingetragen wurde (bei Meetup) oder ob es ein sich einfach jeden Monat zu einem bestimmten Termin wiederholt, aber noch keine Details eingetragen sind.
  - Bei von Hand eingetragenen Terminen, die auch weit in der Zukunft liegen können, sollte man diese mit übertragen, wenn sie aber wiederholt werden ist ab 3 Monaten in der Zukunft wohl sowieso noch kein sinnvoller Inhalt vorhanden und diese sollten dann nicht übertragen werden.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## More detailed (system environment) setup guide for admins

### Meetup API OAuth2 Credentials
How to get the Meetup OAuth2 Authentification set up:

- Go to the meetup web console to tab OAuth Consumers: [Meetup OAUth Consumers](https://secure.meetup.com/meetup_api/oauth_consumers/)
- Click on »Create one now«

I filled this page in like this:
```text
Consumer name: Meetalendar,
Application Website: https://www.hicknhack-software.com/it-events,
Who are you requesting access for?: I am requesting access for my organization,
What is the organization name?: HicknHack Software GmbH,
Phone number: 0123456789,
Description: We use the Meetup API to gather IT-Events in our city and surroundings to display them as part of our Local IT-Event Calendar. Up to now this was done by hand and shall now be replaced by some logic. (The calendar is public and free of cost or commercial interests.),
Platform Terms of Service: Yes, I agree.,
```
-> The phone number is random, please check [our website](https://www.hicknhack-software.com/) if you want to do buisness with us.

With this altered to fit your company and everything setup correctly you might have to wait one or two days until Meetup grants you premission. (When i tried this it seemed to be done by hand.)

When the time has come and your credentials are granted you will have to put them in the credentials.json, that will also have the google calendar credentials, like shown below.

### Google OAuth2 Credentials
Hot to get the Google Calendar OAuth2 Authentification set up:

- Follow this good source: [Google Ruby OAuth2 official Tutorial](https://developers.google.com/calendar/quickstart/ruby) Wich has a nice Button that seems to have a lot of functionaity. If confused it might help make things easier to setup. (Especially getting the credentials.json)
- Good general expanation: [Source of belows steps](https://support.google.com/cloud/answer/6158849?hl=en) -> That i "quopied" it's most relevant section:

```text
_Setting up OAuth 2.0_

To create an OAuth 2.0 client ID in the console:
- Go to the [Google Cloud Platform Console](https://console.cloud.google.com/?pli=1).
- From the projects list, select a project or create a new one.
- If the APIs & services page isn't already open, open the console left side menu and select APIs & services.
- On the left, click Credentials.
- Click New Credentials, then select OAuth client ID.
- Note: If you're unsure whether OAuth 2.0 is appropriate for your project, select Help me choose and follow the instructions to pick the right credentials.

- Select the appropriate application type for your project and enter any additional information required. Application types are described in more detail in the following sections.
- If this is your first time creating a client ID, you can also configure your consent screen by clicking Consent Screen. (The following procedure explains how to set up the Consent screen.) You won't be prompted to configure the consent screen after you do it the first time.
- Click Create client ID
- To delete a client ID, go to the Credentials page, check the box next to the ID, and then click Delete.
```

### Putting both credentials in one credential.json file

Meetalendar will need get the credentials we aquired. It will know where to look when we have set the needed environment variable ```MEETALENDAR_CREDENTIALS_FILEPATH``` to point to the credentials.json file that we will create like so:

Correct annonymified example:
```json
{
  "google_calendar": {
    "installed": {
      "client_id": "123456789-abcdefghijklmnopqrstuvwxyz123456789.apps.googleusercontent.com",
      "project_id": "testprojectidgoogl-123456789",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_secret": "abcdefghijklmnopqrstuvwxyz123456789",
      "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"]
    }
  },
  "meetup": {
    "client_id": "abcdefghijklmnopqrstuvwxyz123456789",
    "client_secret": "abcdefghijklmnopqrstuvwxyz123456789"
  }
}
```

Wich was created from the credentials.json coming from google that looked like so:
```json
{
  "installed": {
    "client_id": "123456789-abcdefghijklmnopqrstuvwxyz123456789.apps.googleusercontent.com",
    "project_id": "testprojectidgoogl-123456789",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "abcdefghijklmnopqrstuvwxyz123456789",
    "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"]
  }
}
```

Basically the google calendar credentials where wrapped and put a nesting lower to allow the choice between loading meetup or google credentials. This allows to only have one environment variable needed to be set up and is also expandable for other credentials shall the need arise.

If you need help setting up the needed ```MEETALENDAR_CREDENTIALS_FILEPATH``` environment variable then find help from this [friendly duck](https://duckduckgo.com/?q=set+environment+variable+for+windows%2Flinux%2Fmac&ia=web).

