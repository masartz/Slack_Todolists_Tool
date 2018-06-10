# Slack Todolists

### Requires

* cpanm
* Carton

### How To Use

* carton install
* EDIT config/config.pl (COPY FROM config/config.pl.sample)
* carton exec perl cron/save_todolists.pl
* carton exec plackup app.psgi

### LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
