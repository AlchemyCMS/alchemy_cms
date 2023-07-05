# Changelog

## 7.0.0 (2023-07-05)

- Update to Alchemy 7.0 [#173](https://github.com/AlchemyCMS/alchemy-devise/pull/173) ([tvdeyen](https://github.com/tvdeyen))

## 6.3.0 (2023-07-05)

- Remove Alchemy 7.0 and 6.0 support [#174](https://github.com/AlchemyCMS/alchemy-devise/pull/174) ([tvdeyen](https://github.com/tvdeyen))
- Use standard.rb to lint code [#166](https://github.com/AlchemyCMS/alchemy-devise/pull/166) ([tvdeyen](https://github.com/tvdeyen))
- Update brakeman scan action [#165](https://github.com/AlchemyCMS/alchemy-devise/pull/165) ([tvdeyen](https://github.com/tvdeyen))

## 6.2.0 (2023-04-01)

- Add Alchemy 7 support [#164](https://github.com/AlchemyCMS/alchemy-devise/pull/164) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade rspec-rails to version 6.0.1 [#153](https://github.com/AlchemyCMS/alchemy-devise/pull/153) ([depfu](https://github.com/apps/depfu))

## 6.1.0 (2023-01-20)

- Remove Alchemy 5.3 support [#158](https://github.com/AlchemyCMS/alchemy-devise/pull/158) ([tvdeyen](https://github.com/tvdeyen))
- Update gemspec to Alchemy below 7.0 [#156](https://github.com/AlchemyCMS/alchemy-devise/pull/156) ([kulturbande](https://github.com/kulturbande))
- use code climate gh action [#147](https://github.com/AlchemyCMS/alchemy-devise/pull/147) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade rspec-rails to version 5.1.2 [#138](https://github.com/AlchemyCMS/alchemy-devise/pull/138) ([depfu](https://github.com/apps/depfu))

## 6.0.0 (2022-04-24)

- Alchemy 6 compatibility [#137](https://github.com/AlchemyCMS/alchemy-devise/pull/137) ([tvdeyen](https://github.com/tvdeyen))
- Use minor versions for Ruby in CI [#131](https://github.com/AlchemyCMS/alchemy-devise/pull/131) ([mamhoff](https://github.com/mamhoff))
- Migrate to GH actions as CI [#122](https://github.com/AlchemyCMS/alchemy-devise/pull/122) ([tvdeyen](https://github.com/tvdeyen))
- Allow Alchemy 6 [#119](https://github.com/AlchemyCMS/alchemy-devise/pull/119) ([tvdeyen](https://github.com/tvdeyen))

## 5.1.0 (2021-01-13)

- Remove support for old Alchemy versions [#118](https://github.com/AlchemyCMS/alchemy-devise/pull/118) ([tvdeyen](https://github.com/tvdeyen))
- Admin users list fixes [#117](https://github.com/AlchemyCMS/alchemy-devise/pull/117) ([tvdeyen](https://github.com/tvdeyen))
- Use Alchemy::User as class in ability [#116](https://github.com/AlchemyCMS/alchemy-devise/pull/116) ([tvdeyen](https://github.com/tvdeyen))
- Fixate sassc gem to 2.1.0 [#115](https://github.com/AlchemyCMS/alchemy-devise/pull/115) ([tvdeyen](https://github.com/tvdeyen))
- Use content_for :toolbar instead of toolbar [#114](https://github.com/AlchemyCMS/alchemy-devise/pull/114) ([tvdeyen](https://github.com/tvdeyen))

## 5.0.1 (2020-11-22)

- Require alchemy/version in controllers using ssl_required [#113](https://github.com/AlchemyCMS/alchemy-devise/pull/113) ([tvdeyen](https://github.com/tvdeyen))
- Use absolute paths in Alchemy module definition [#106](https://github.com/AlchemyCMS/alchemy-devise/pull/106) ([tvdeyen](https://github.com/tvdeyen))

## 4.6.0 (2020-10-16)

- Remove require_ssl from User Sessions Controller for Alchemy 5+ [#102](https://github.com/AlchemyCMS/alchemy-devise/pull/102) ([mamhoff](https://github.com/mamhoff))

## 4.5.0 (2020-04-04)

- Remove alchemy controller requests test helper [#100](https://github.com/AlchemyCMS/alchemy-devise/pull/100) ([tvdeyen](https://github.com/tvdeyen))
- Move session controllers into admin module namespace [#97](https://github.com/AlchemyCMS/alchemy-devise/pull/97) ([tvdeyen](https://github.com/tvdeyen))

## 4.4.0 (2019-01-09)

- Set Alchemy.logout_method to Devise.sign_out_via [#96](https://github.com/AlchemyCMS/alchemy-devise/pull/96) ([tvdeyen](https://github.com/tvdeyen))
- Allow Alchemy 5.0 [#95](https://github.com/AlchemyCMS/alchemy-devise/pull/95) ([tvdeyen](https://github.com/tvdeyen))
- Remove gender [#94](https://github.com/AlchemyCMS/alchemy-devise/pull/94) ([rmparr](https://github.com/rmparr))

## 4.3.1 (2019-11-28)

- add config/manifest.js to dummy app [#93](https://github.com/AlchemyCMS/alchemy-devise/pull/93) ([rmparr](https://github.com/rmparr))
- Use at least Devise 4.7.1 [#90](https://github.com/AlchemyCMS/alchemy-devise/pull/90) ([tvdeyen](https://github.com/tvdeyen))
- Rename Alchemy::BaseController extension constant [#87](https://github.com/AlchemyCMS/alchemy-devise/pull/87) ([tvdeyen](https://github.com/tvdeyen))

## 4.3.0 (2019-08-23)

- Move test dependencies [#86](https://github.com/AlchemyCMS/alchemy-devise/pull/86) ([tvdeyen](https://github.com/tvdeyen))
- Test with Rails 6 [#85](https://github.com/AlchemyCMS/alchemy-devise/pull/85) ([tvdeyen](https://github.com/tvdeyen))

## 4.2.1 (2019-05-15)

- Remove test files from built Ruby gem [#82](https://github.com/AlchemyCMS/alchemy-devise/pull/82) ([tvdeyen](https://github.com/tvdeyen))
- Run CSRF protection before all other controller filters [#81](https://github.com/AlchemyCMS/alchemy-devise/pull/81) ([tvdeyen](https://github.com/tvdeyen))

## 4.2.0 (2019-04-01)

- Do not store screen size at login [#78](https://github.com/AlchemyCMS/alchemy-devise/pull/78) ([tvdeyen](https://github.com/tvdeyen))
- Security: Use at least Devise 4.6 [#78](https://github.com/AlchemyCMS/alchemy-devise/pull/78) ([tvdeyen](https://github.com/tvdeyen))
- Fix dummy app rails version [#76](https://github.com/AlchemyCMS/alchemy-devise/pull/76) ([tvdeyen](https://github.com/tvdeyen))
- Fix translation key on user admin page [#75](https://github.com/AlchemyCMS/alchemy-devise/pull/75) ([mamhoff](https://github.com/mamhoff))


## 4.1.0 (2018-09-22)

- Only allow Alchemy > 4.1 [#72](https://github.com/AlchemyCMS/alchemy-devise/pull/72) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade dummy app rails version to 5.2.1 [#71](https://github.com/AlchemyCMS/alchemy-devise/pull/71) ([depfu](https://github.com/marketplace/depfu))
- Build for Rails 5.1 [#70](https://github.com/AlchemyCMS/alchemy-devise/pull/70) ([tvdeyen](https://github.com/tvdeyen))
- Fixes localization specs [#69](https://github.com/AlchemyCMS/alchemy-devise/pull/69) ([tvdeyen](https://github.com/tvdeyen))
- Removes translations [#68](https://github.com/AlchemyCMS/alchemy-devise/pull/68) ([tvdeyen](https://github.com/tvdeyen))
- New login screen that fit the new color theme [#67](https://github.com/AlchemyCMS/alchemy-devise/pull/67) ([tvdeyen](https://github.com/tvdeyen))
- Use Alchemy's Taggable module [#66](https://github.com/AlchemyCMS/alchemy-devise/pull/66) ([tvdeyen](https://github.com/tvdeyen))
- Upgrade pg to version 1.0.0 [#65](https://github.com/AlchemyCMS/alchemy-devise/pull/65) ([depfu](https://github.com/marketplace/depfu))
- FontAwesome icons [#64](https://github.com/AlchemyCMS/alchemy-devise/pull/64) ([tvdeyen](https://github.com/tvdeyen))
- Fix postgresql builds [#63](https://github.com/AlchemyCMS/alchemy-devise/pull/63) ([tvdeyen](https://github.com/tvdeyen))

## 4.0.0 (2017-11-06)

- Update dummy app layout for Alchemy 4.0 [#62](https://github.com/AlchemyCMS/alchemy-devise/pull/62) ([tvdeyen](https://github.com/tvdeyen))
- Alchemy 4.0 [#61](https://github.com/AlchemyCMS/alchemy-devise/pull/61) ([tvdeyen](https://github.com/tvdeyen))
- Send code coverage results after successful build [#60](https://github.com/AlchemyCMS/alchemy-devise/pull/60) ([tvdeyen](https://github.com/tvdeyen))
- Allow to configure devise modules [#59](https://github.com/AlchemyCMS/alchemy-devise/pull/59) ([tvdeyen](https://github.com/tvdeyen))
- Rails 5, Alchemy 4, Devise 4 [#58](https://github.com/AlchemyCMS/alchemy-devise/pull/58) ([tvdeyen](https://github.com/tvdeyen))
