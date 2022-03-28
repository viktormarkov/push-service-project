# Push Service Project

Demo project to try dry-rb stack.

### Description

- Users use the service to send push notifications.
- A user should have one of two roles: admin or manager.
- Admins are able to create managers accounts.
- Admins are able to choose a city to send a push message.
- Managers are related to one city and able to send push notifications only to their cities.
- The Service gets push message device tokens via API.
- Device tokens are related to a city.

### Requirements
- Ruby 2.7.1
- Ruby on Rails 6.1.4
- PostgreSQL