%%--------------------------------------------------------------------
%% Copyright (c) 2013-2013-2019 EMQ Enterprise, Inc. (http://emqtt.io)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_vm_mon_SUITE).

-compile(export_all).
-compile(nowarn_export_all).

-include_lib("eunit/include/eunit.hrl").

-include_lib("common_test/include/ct.hrl").

all() -> [t_api].

init_per_suite(Config) ->
    application:ensure_all_started(sasl),
    Config.

end_per_suite(_Config) ->
    application:stop(sasl).

t_api(_) ->
    gen_event:swap_handler(alarm_handler, {emqx_alarm_handler, swap}, {alarm_handler, []}),
    {ok, _} = emqx_vm_mon:start_link([{check_interval, 1},
                                      {process_high_watermark, 0},
                                      {process_low_watermark, 0.6}]),
    timer:sleep(2000),
    ?assertEqual(true, lists:keymember(too_many_processes, 1, alarm_handler:get_alarms())),
    emqx_vm_mon:set_process_high_watermark(0.8),
    emqx_vm_mon:set_process_low_watermark(0.75),
    ?assertEqual(0.8, emqx_vm_mon:get_process_high_watermark()),
    ?assertEqual(0.75, emqx_vm_mon:get_process_low_watermark()),
    timer:sleep(3000),
    ?assertEqual(false, lists:keymember(too_many_processes, 1, alarm_handler:get_alarms())),
    emqx_vm_mon:set_check_interval(20),
    ?assertEqual(20, emqx_vm_mon:get_check_interval()),
    ok.
