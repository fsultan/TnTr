package TnTr::Dispatch;
use strict;
use base 'CGI::Application::Dispatch';

#set TNTR_APP_BASE as env var in shell or web server
my $app_base = $ENV{'TNTR_APP_BASE'};

sub dispatch_args {
    return {
        debug => 1,
        prefix => 'TnTr',
        args_to_new => {
             TMPL_PATH  => $app_base . 'private/templates/',
#             APP_CONFIG => $app_base . 'private/config/default.cfg',
        },
        #table => [ '' => { app => 'Main', rm => 'welcome' }, ],
        table => [ 
            '' => { app => 'Main', rm => '' },
            'welcome' => { app => 'Main', rm => '' },
            'default' => { app => 'Main', rm => '' },
            'login' => { app=> 'Main', rm => 'login' },
            'logout' => { app=> 'Main', rm => 'logout' },
            'rights/edit/:owner_type/:owner_id/:app_name/:app_id[get]' => { app => 'Rights', rm=> 'gedit_display'},
            'rights/edit/:owner_type/:owner_id/:app_name/:app_id[post]' => { app => 'Rights', rm=> 'gedit_process'},
            ':app' => { },
            ':app/show/:id' => { rm => 'show' },
            ':app/edit/:id[get]' => { rm => 'edit_display' },
            ':app/edit/:id[post]' => { rm => 'edit_process' },
            ':app/create[get]' => { rm => 'create_display' },
            ':app/create[post]' => { rm => 'create_process' },
            ':app/update_memberships/:owner_type/:owner_id[get]' => { rm => 'update_memberships_display' },
            ':app/update_memberships/:owner_type/:owner_id[post]' => { rm => 'update_memberships_process' },
            ':app/:rm' => { },
            ':app/:rm/*' => { },
            #'logout'    => { rm => 'logout' },
        ],
        error_document => '</error%s.html',
    };
}

1;
