-- 修改20250610 by superzjg@qq.com

local t = require"luci.sys"
local m

m = Map("rustdesk", translate("RustDesk Server"), translate("ID / Relay Server configuration").. "<br/>" .. [[<a href="https://github.com/rustdesk/rustdesk-server" target="_blank">]] .. translate("Server") .. [[</a>]] .. [[<a href="https://github.com/rustdesk/rustdesk" target="_blank">]] .. translate("&nbsp;&nbsp;&nbsp;Client") .. [[</a>]])
m:section(SimpleSection).template="rustdesk/rustdesk_status"

t=m:section(TypedSection,"rustdesk")
t.addremove = false
t.anonymous = true

t:tab("base",translate("Base"))
t:tab("service",translate("ID/Registration service"))
t:tab("relay",translate("Relay service"))

enable = t:taboption("base", Flag, "enabled", translate("Enable ID Server"))
enable.rmempty=false
enable_r = t:taboption("base", Flag, "enabled_relay", translate("Enable Relay Server"))
enable_r.rmempty=false

s_log = t:taboption("base", Flag, "server_log", translate("Enable log"), translate("Logfile /var/log/rustdesk.log can be viewed through the top tab View"))
s_log.default = 0

binDir = t:taboption("base", Value, "bin_dir", translate("RustDesk binary files location"))
binDir.datatype = "string"
binDir.default = "/usr/bin"
binDir.rmempty = false
binDir.description = translate("Path of binaries hbbs and hbbr, do not add / at the end")

info = t:taboption("base",DummyValue, "moreinfo", translate("Note"))
info.default = "Ports："
info.description = translate("Default ports: hbbs 21114(tcp)，21115(tcp), 21116(tcp/udp), 21118(tcp). hbbr 21117(tcp), 21119(tcp) / WebConsole(PRO) 21114, NAT test 21115，ID Reg-Heartbeat 21116/UDP，21116-21119/TCP Hole/Service")
firewall = t:taboption("base",ListValue, "set_firewall", translate("FW Rules"), translate("Check: start the service, no fw rules added, if service disabled it does not delete rules<br/> Force: add/delete fw rules at start/stop"))
firewall:value("no", translate("No action"))
firewall:value("check", translate("Check"))
firewall:value("force", translate("Force"))
firewall.default = "no"

TCPs = t:taboption("base",Value, "tcp_ports", translate("TCP Ports"),translate("To define multiple values space can be used, also dash - for ranges, if not defined default ones will be used"))
TCPs:depends("set_firewall", "check")
TCPs:depends("set_firewall", "force")
TCPs.placeholder = "21115-21119"
UDPs = t:taboption("base",Value, "udp_ports", translate("UDP Ports"))
UDPs:depends("set_firewall", "check")
UDPs:depends("set_firewall", "force")
UDPs.placeholder = "21116"

viewkey = t:taboption("base",Button, "view_key", translate("View key"),translate("Key will be created after the service starts, you can click on View to read id_ed25519.pub key"))
viewkey.rawhtml = true
viewkey.template = "rustdesk/view_key"

del_key = t:taboption("base",Button,"del_key",translate("Delete key file"))
del_key.description = translate("Delete key and restart server to generate new key")
function del_key.write()
luci.sys.exec("rm -f $(uci get rustdesk.@rustdesk[0].bin_dir)/id_ed25519*")
end

port = t:taboption("service", Value, "server_port", translate("Port"))
port.datatype = "range(1,65535)"
port.placeholder = "21116"
port.description = translate("Listening port，default 211166")

key = t:taboption("service",Value, "server_key", translate("key"))
key.datatype = "string"
key.description = translate("Only clients with the same key are allowed. If left blank, default key id_ed25519.pub will be used")

relay_server = t:taboption("service",Value, "server_relay_servers", translate("Relay Server"))
relay_server.datatype = "string"
relay_server.description = translate("Relay server, separated by a colon. LAN Side,WAN Side")

rendezvous_server = t:taboption("service",Value, "server_rendezvous_servers", translate("ID/registration Server"))
rendezvous_server.datatype = "string"
rendezvous_server.description = translate("ID/registered server, separated by a colon")

rmem = t:taboption("service",Value, "server_rmem", translate("UDP recv buffer"))
rmem.datatype = "range(0,52428800)"
rmem.placeholder = "0"
rmem.description = translate("UDP recv buffer size (set system rmem_max first), default value 0")

serial = t:taboption("service",Value, "server_serial", translate("Serial number"))
serial.placeholder = "0"
serial.description = translate("configuration update serial number, default 0")

software_url = t:taboption("service",Value,"server_software_url", translate("Download Link"))
software_url.datatype = "string"
software_url.description = translate("Download url of the latest version of RustDesk")

relay_port = t:taboption("relay", Value, "relay_port", translate("Port"))
relay_port.datatype = "range(1,65535)"
relay_port.placeholder = "21117"
relay_port.description = translate("Listening port，default 21117")

relay_key = t:taboption("relay",Value, "relay_key", translate("key"))
relay_key.datatype = "string"
relay_key.description = translate("Only clients with the same key are allowed. If left blank, default key id_ed25519.pub will be used")

return m
