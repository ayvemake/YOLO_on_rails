.
├── app
│   ├── assets
│   │   ├── builds
│   │   │   └── tailwind.css
│   │   ├── config
│   │   │   └── manifest.js
│   │   ├── images
│   │   ├── stylesheets
│   │   │   └── application.css
│   │   └── tailwind
│   │       └── application.css
│   ├── channels
│   │   ├── analysis_channel.rb
│   │   └── application_cable
│   │       ├── channel.rb
│   │       └── connection.rb
│   ├── controllers
│   │   ├── analyses_controller.rb
│   │   ├── api
│   │   │   └── v1
│   │   ├── application_controller.rb
│   │   ├── components_controller.rb
│   │   ├── concerns
│   │   ├── dashboard_controller.rb
│   │   └── defect_detections_controller.rb
│   ├── helpers
│   │   ├── analyses_helper.rb
│   │   └── application_helper.rb
│   ├── javascript
│   │   ├── application.js
│   │   ├── channels
│   │   │   ├── analysis_channel.js
│   │   │   └── consumer.js
│   │   └── controllers
│   │       ├── analysis_controller.js
│   │       ├── application.js
│   │       ├── hello_controller.js
│   │       └── index.js
│   ├── jobs
│   │   ├── analysis_job.rb
│   │   └── application_job.rb
│   ├── mailers
│   │   └── application_mailer.rb
│   ├── models
│   │   ├── analysis.rb
│   │   ├── analysis_result.rb
│   │   ├── application_record.rb
│   │   ├── component.rb
│   │   ├── concerns
│   │   └── defect_detection.rb
│   ├── services
│   │   ├── ai_service.rb
│   │   ├── home_assistant_service.rb
│   │   ├── mcp_service.rb
│   │   └── wafer_defect_detector.rb
│   └── views
│       ├── analyses
│       │   ├── _analysis_result.html.erb
│       │   ├── index.html.erb
│       │   ├── new.html.erb
│       │   └── show.html.erb
│       ├── dashboard
│       │   └── index.html.erb
│       ├── defect_detections
│       │   ├── new.html.erb
│       │   └── show.html.erb
│       ├── kaminari
│       │   └── tailwind
│       └── layouts
│           ├── application.html.erb
│           ├── mailer.html.erb
│           └── mailer.text.erb
├── backend
│   ├── detect_wafer.py
│   ├── setup_wafer_model.sh
│   └── weights
├── bin
│   ├── bundle
│   ├── dev
│   ├── docker-entrypoint
│   ├── importmap
│   ├── rails
│   ├── rake
│   └── setup
├── config
│   ├── application.rb
│   ├── boot.rb
│   ├── cable.yml
│   ├── credentials.yml.enc
│   ├── database.yml
│   ├── environment.rb
│   ├── environments
│   │   ├── development.rb
│   │   ├── production.rb
│   │   └── test.rb
│   ├── importmap.rb
│   ├── initializers
│   │   ├── ai_models_config.rb
│   │   ├── assets.rb
│   │   ├── content_security_policy.rb
│   │   ├── filter_parameter_logging.rb
│   │   ├── inflections.rb
│   │   ├── mcp_server_config.rb
│   │   ├── permissions_policy.rb
│   │   └── sidekiq.rb
│   ├── locales
│   │   └── en.yml
│   ├── master.key
│   ├── puma.rb
│   ├── routes.rb
│   └── storage.yml
├── config.ru
├── db
│   ├── migrate
│   │   ├── 20250306193412_create_components.rb
│   │   ├── 20250306193413_create_analyses.rb
│   │   ├── 20250306193414_create_analysis_results.rb
│   │   ├── 20250306193418_create_active_storage_tables.active_storage.rb
│   │   ├── 20250306212100_change_components_to_jsonb.rb
│   │   ├── 20250306212612_rename_components_to_api_data.rb
│   │   ├── 20250306212916_add_api_data_to_analyses.rb
│   │   ├── 20250306213124_add_raw_data_to_analysis_results.rb
│   │   ├── 20250310152927_create_defect_detections.rb
│   │   ├── YYYYMMDDHHMMSS_add_api_data_to_analyses.rb
│   │   ├── YYYYMMDDHHMMSS_add_processing_time_to_analyses.rb
│   │   ├── YYYYMMDDHHMMSS_add_raw_data_to_analysis_results.rb
│   │   ├── YYYYMMDDHHMMSS_change_components_to_jsonb.rb
│   │   ├── YYYYMMDDHHMMSS_create_analyses.rb
│   │   ├── YYYYMMDDHHMMSS_create_analysis_results.rb
│   │   ├── YYYYMMDDHHMMSS_create_defect_detections.rb
│   │   └── YYYYMMDDHHMMSS_rename_components_to_api_data.rb
│   ├── schema.rb
│   └── seeds.rb
├── Dockerfile
├── Gemfile
├── Gemfile.lock
├── lib
│   ├── assets
│   └── tasks
├── log
│   └── development.log
├── Procfile.dev
├── project_structure.md
├── public
│   ├── 404.html
│   ├── 422.html
│   ├── 500.html
│   ├── apple-touch-icon.png
│   ├── apple-touch-icon-precomposed.png
│   ├── favicon.ico
│   └── robots.txt
├── Rakefile
├── README.md
├── storage
│   ├── 03
│   │   ├── c5
│   │   │   └── 03c5n170t65xadx1l7k5v269bvh7
│   │   └── yw
│   │       └── 03ywqgwdvwh2gje0a2zxlendo0ym
│   ├── 09
│   │   └── wh
│   │       └── 09whqbd74vsm5n9g071uwjfx6u4l
│   ├── 17
│   │   └── p8
│   │       └── 17p86gvya6uip03k4tkvluvfwzc2
│   ├── 1d
│   │   └── 7f
│   │       └── 1d7fe1kag45c5738vh1pgou37nzk
│   ├── 1f
│   │   └── 8k
│   │       └── 1f8k47f3hfnxhw8c7w4h0qtdgqkc
│   ├── 1q
│   │   └── qi
│   │       └── 1qqi8ri49eleamif31ksf4jeygey
│   ├── 1v
│   │   └── 80
│   │       └── 1v80jceg7co6b5b0dq06r0sixn8s
│   ├── 2z
│   │   └── xj
│   │       └── 2zxj4d6k50avqekcnv1ep5erhjtg
│   ├── 39
│   │   └── qr
│   │       └── 39qr4envnj24kswjydypt6sye78h
│   ├── 3c
│   │   └── ew
│   │       └── 3cewr52mcph2xe4unak9bz3vuyss
│   ├── 3p
│   │   └── yi
│   │       └── 3pyi1vek6kv45wjwjac2bwvoydda
│   ├── 44
│   │   └── 7x
│   │       └── 447xp002x4kmuu86bwt9bg0pkkvg
│   ├── 54
│   │   └── p5
│   │       └── 54p5wdd4x22ql65gb1wz7pza0c7p
│   ├── 5v
│   │   └── 7b
│   │       └── 5v7bj37ya5ajn1t7e8qj1jho5r4f
│   ├── 6m
│   │   └── ej
│   │       └── 6mejhhu04n8mmjay2m7rc2pk5u8k
│   ├── 6w
│   │   └── e4
│   │       └── 6we4yvrroskyd7eu3xd84zvtvllk
│   ├── 7a
│   │   └── j0
│   │       └── 7aj0qreb37aatjh20fe8xx9dltqo
│   ├── 7w
│   │   └── g0
│   │       └── 7wg076wduavtha6khf2e8egwu8km
│   ├── 88
│   │   └── mo
│   │       └── 88moriipv08c67bfj2zv81wftyks
│   ├── 8r
│   │   └── r0
│   │       └── 8rr0loo96yrjdezbwl5rf2rx4xw5
│   ├── 8z
│   │   └── up
│   │       └── 8zupdih7zdqw88jhk5en1j6y4q0b
│   ├── 93
│   │   └── fr
│   │       └── 93fr2jeqelg0se2baf8cp046659t
│   ├── 9c
│   │   └── td
│   │       └── 9ctdnyxmt6omoo7roenz36xmgfm2
│   ├── 9t
│   │   └── tk
│   │       └── 9ttkqhbhzkb5d9hkwfhkpodb3fu6
│   ├── aa
│   │   └── me
│   │       └── aamevvjaj5tx5q73nkbsd98lf653
│   ├── al
│   │   └── 61
│   │       └── al61ddi4z82rs52jp7iiu4yr382x
│   ├── b1
│   │   └── mg
│   │       └── b1mgiqqbctov36k1q6e5pbfcaa0p
│   ├── bc
│   │   └── fx
│   │       └── bcfxid5inwqcwdmfiptbpu395bjf
│   ├── br
│   │   └── a4
│   │       └── bra4u2vvw3lqqr2y3pe5ldzhsk1p
│   ├── by
│   │   └── j1
│   │       └── byj1c4n7jb4lfp1dbgj56ds1rqg9
│   ├── cl
│   │   └── eh
│   │       └── clehscqi9m9odloasnkpbtb5ucry
│   ├── cu
│   │   └── t1
│   │       └── cut1pu8n8s9sejkkqlu6a1s416ac
│   ├── d6
│   │   └── dx
│   │       └── d6dxs6mfistdjcfh1l24xxlh4gge
│   ├── ec
│   │   └── 1v
│   │       └── ec1vbjjan9zhie2nckx0aay17f2k
│   ├── eu
│   │   └── jp
│   │       └── eujpvjj51v9cdzx7wiunltytatsn
│   ├── f8
│   │   └── el
│   │       └── f8eloqe6lxohb3fznpufw8ynaucm
│   ├── fw
│   │   └── j1
│   │       └── fwj1c4zza8ihdkdgincxqskoqcv0
│   ├── fx
│   │   └── yo
│   │       └── fxyoc4a37g2f4r2k4d7dahtlm5qc
│   ├── g1
│   │   └── eu
│   │       └── g1euskhmj2yp5vibys2ozkej2otb
│   ├── g9
│   │   └── 7j
│   │       └── g97j3pw1ctroklewg3xk6gkdplhg
│   ├── ha
│   │   └── px
│   │       └── hapxj2tsq5zvxm2rrhs5e31hgc5m
│   ├── hc
│   │   └── 3w
│   │       └── hc3wmw6lwm22vwh74fmfl722gjmq
│   ├── ie
│   │   └── pi
│   │       └── iepia7pb18ot38y1j3w6hc2329hd
│   ├── j6
│   │   └── cn
│   │       └── j6cn5bu3eqlatqwai74juxvkx9qn
│   ├── j8
│   │   └── zv
│   │       └── j8zveb7u4ad8tlsves6d6013nyqv
│   ├── jh
│   │   └── 16
│   │       └── jh16bs86klk5kwdzqx1x7iblfi2k
│   ├── l7
│   │   └── fy
│   │       └── l7fyne1g6eh9qakvva3y3ktaewzr
│   ├── m7
│   │   └── 46
│   │       └── m746xs1afyh06feazb9s9jddb1af
│   ├── mb
│   │   └── 3v
│   │       └── mb3vkqvwal78atxjsh7wxh7xzlm1
│   ├── me
│   │   └── yi
│   │       └── meyi3y0hmhbcluq9sub96eafw4lh
│   ├── mm
│   │   └── 1n
│   │       └── mm1nia9jce13lhr7hdj3x68oupbk
│   ├── mz
│   │   └── 8q
│   │       └── mz8q9ebfzb5sg081inek5k6n9d8v
│   ├── n4
│   │   └── 1f
│   │       └── n41f3n35pp28y5t5sdvpyp64o095
│   ├── np
│   │   └── 4q
│   │       └── np4q8ncn47ul82986u0eyp8ilw72
│   ├── nr
│   │   └── 1b
│   │       └── nr1bzkctid9y2sfuq837zyxo0cmu
│   ├── nw
│   │   └── ud
│   │       └── nwudd7frq4ln09q9gppuhj3jie2d
│   ├── oq
│   │   └── 3p
│   │       └── oq3pgdr9gkfr9oac9aczqn7pqw4f
│   ├── ou
│   │   └── wl
│   │       └── ouwlm9kr0wtestahdz6iog8gv8tu
│   ├── p3
│   │   └── p6
│   │       └── p3p6v3na1p7x0rwesok1jlaqxn7q
│   ├── pc
│   │   └── 9v
│   │       └── pc9v445rndghe4bn6455lhdi6nwj
│   ├── pm
│   │   └── xj
│   │       └── pmxjls8kz7fz4yrk95cg03059y6r
│   ├── pt
│   │   └── fh
│   │       └── ptfho1o4rp35u7b81kuxdl8xda95
│   ├── q9
│   │   └── 14
│   │       └── q914bxqa3ktg4eiz1zx5ugsrvjiy
│   ├── qs
│   │   └── zq
│   │       └── qszqa7ggeoc5tsv84qx1g3te7p46
│   ├── r4
│   │   ├── 3x
│   │   │   └── r43xge0bxfavqakxi3k5ivpwnka9
│   │   └── y2
│   │       └── r4y2zgkk4a45a1icn4wnssioz90w
│   ├── r6
│   │   └── a1
│   │       └── r6a1ve2q14vw3i6ipdspx5qxh4zh
│   ├── rh
│   │   └── ma
│   │       └── rhma1gwp3cdzlusyjx6w3ctmfwgu
│   ├── si
│   │   └── zd
│   │       └── sizds70ject2pmc63v50z0rpreb7
│   ├── sx
│   │   ├── l8
│   │   │   └── sxl86r1jvgn4fx44uy4xmvd64n44
│   │   └── q8
│   │       └── sxq8lpdq759h0776hri4tnfwch7u
│   ├── t6
│   │   └── xb
│   │       └── t6xbmbab8d7yjz89ph1u9hhyxerm
│   ├── ta
│   │   ├── 24
│   │   │   └── ta24tcullvvzx4q5jykm7s0p0hla
│   │   └── 98
│   │       └── ta98ovxhpmtsod17a1eyntldp51q
│   ├── us
│   │   └── z1
│   │       └── usz11wsp0puxlsg4zc8xwgm5x6ok
│   ├── vd
│   │   └── 3k
│   │       └── vd3k7ce67klrhtz6xhet2le2eauf
│   ├── vi
│   │   └── 7e
│   │       └── vi7e3bw1yqadezzsb71fybv9essh
│   ├── vk
│   │   └── ll
│   │       └── vkllqlffhp1vbm8lidzg0ehousoq
│   ├── vv
│   │   └── kt
│   │       └── vvktrrndel4faqogvvoi4d8soa8a
│   ├── vz
│   │   └── z5
│   │       └── vzz528exve84btdg7zav9a0s8lch
│   ├── xd
│   │   └── d6
│   │       └── xdd6ziedg9r110sbnch3m0gkppr5
│   ├── xu
│   │   └── iq
│   │       └── xuiqlu6801m1nrzgqxairz6xvoem
│   ├── xz
│   │   └── 67
│   │       └── xz67bpbjw9tyuicj3ct9c8m27kkq
│   ├── yg
│   │   └── tz
│   │       └── ygtzrlv62kw7zgmt6rgt3hroof3o
│   ├── yk
│   │   └── 6y
│   │       └── yk6yq7505jesahm2cslyn1v71lkz
│   ├── yu
│   │   └── 6p
│   │       └── yu6pr7tur6g3saxrnzqtm60o4egy
│   ├── z9
│   │   └── nx
│   │       └── z9nx8xo0k39788vor8pxwepyfvgn
│   ├── za
│   │   └── hi
│   │       └── zahiw86q9h1jkgljh8h5g6ewtwdc
│   ├── zb
│   │   └── 4o
│   │       └── zb4o3k9iglt9b1yb7dnpufi2x3qt
│   ├── zd
│   │   └── pc
│   │       └── zdpc22dv852aomd5emikvs2ecd3x
│   └── zo
│       └── c0
│           └── zoc0x0wur9ijw5ncpj6dds26dv43
├── test
│   ├── application_system_test_case.rb
│   ├── channels
│   │   └── application_cable
│   │       └── connection_test.rb
│   ├── controllers
│   ├── fixtures
│   │   └── files
│   ├── helpers
│   ├── integration
│   ├── mailers
│   ├── models
│   ├── system
│   └── test_helper.rb
├── tmp
│   ├── cache
│   │   ├── assets
│   │   │   └── sprockets
│   │   └── bootsnap
│   │       ├── compile-cache-iseq
│   │       ├── compile-cache-yaml
│   │       └── load-path-cache
│   ├── pids
│   ├── restart.txt
│   ├── sockets
│   └── storage
└── vendor
    └── javascript

248 directories, 207 files
