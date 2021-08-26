<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>软件中心 - npc</title>
<link rel="stylesheet" type="text/css" href="index_style.css"/> 
<link rel="stylesheet" type="text/css" href="form_style.css"/>
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">   
<style>
input[type=button]:focus {
  outline: none;
}
.popup_bar_bg_ks{
  position:fixed;  
  margin: auto;
  top: 0;
  left: 0;
  width:100%;
  height:100%;
  z-index:99;
  /*background-color: #444F53;*/
  filter:alpha(opacity=90);  /*IE5、IE5.5、IE6、IE7*/
  background-repeat: repeat;
  visibility:hidden;
  overflow:hidden;
  /*background: url(/images/New_ui/login_bg.png);*/
  background:rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important;
  background-position: 0 0;
  background-size: cover;
  opacity: .94;
}
.loadingBarBlock{
  width:740px;
}
.loading_block_spilt {
  background: #656565;
  height: 1px;
  width: 98%;
}
</style>
<link rel="stylesheet" type="text/css" href="usp_style.css"/>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/calendar/jquery-ui.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/res/npc-menu.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script>
var db_npc = {};
var params_input = [
  "npc_common_vkey", 
  "npc_common_server_ip",
  "npc_common_server_port",
];

var params_check = ["npc_enable"];
var  refresh_flag;
var count_down;
String.prototype.myReplace = function(f, e){
  var reg = new RegExp(f, "g"); 
  return this.replace(reg, e); 
}
function init(){
  show_menu(menu_hook);
  get_dbus_data();
  get_status();
  conf2obj();
  version_show();
  hook_event();
}
function get_dbus_data() {
  $.ajax({
    type: "GET",
    url: "/_api/npc",
    dataType: "json",
    async: false,
    success: function(data) {
      db_npc = data.result[0];
      console.log("db_npc:", db_npc);
    }
  });
}
function get_status(){
  var id = parseInt(Math.random() * 100000000);
  var postData = {"id": id, "method": "npc_status.sh", "params":[1], "fields": ""};
  $.ajax({
    type: "POST",
    cache:false,
    url: "/_api/",
    data: JSON.stringify(postData),
    dataType: "json",
    success: function(response){
      if(response.result){
        E("status").innerHTML = response.result;
        setTimeout("get_status();", 5000);
      }
    },
    error: function(xhr){
      console.log(xhr)
      setTimeout("get_status();", 15000);
    }
  });
}
function conf2obj(){
  for (var i = 0; i < params_input.length; i++) {
    if(db_npc[params_input[i]]){
      E(params_input[i]).value = db_npc[params_input[i]];
    }
  }
  for (var i = 0; i < params_check.length; i++) {
    if(db_npc[params_check[i]]){
      E(params_check[i]).checked = db_npc[params_check[i]] == 1 ? true : false
    }
  }
}
function save() {
  // if(!E(npc_common_dashboard_port).value || !E(npc_common_dashboard_user).value || !E(npc_common_dashboard_pwd).value || !E(npc_common_bind_port).value || !E(npc_common_privilege_token).value || !E(npc_common_vhost_http_port).value || !E(npc_common_vhost_https_port).value || !E(npc_common_max_pool_count).value || !E(npc_common_cron_time).value){
  if(
    !E(npc_common_vkey).value 
    || !E(npc_common_server_ip).value
    || !E(npc_common_server_port).value
  ){
    alert("提交的表单不能为空!");
    return false;
  }
  for (var i = 0; i < params_input.length; i++) {
    if (E(params_input[i]).value) {
      db_npc[params_input[i]] = E(params_input[i]).value;
    }else{
      db_npc[params_input[i]] = "";
    }
  }
  for (var i = 0; i < params_check.length; i++) {
    db_npc[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
  }
  var uid = parseInt(Math.random() * 100000000);
  console.log("uid :", uid);
  var postData = {"id": uid, "method": "npc_config.sh", "params": ["web_submit"], "fields": db_npc };
  console.log("postData :", postData);
  $.ajax({
    url: "/_api/",
    cache: false,
    type: "POST",
    data: JSON.stringify(postData),
    dataType: "json",
    success: function(response) {
      console.log("response: ", response);
      if (response.result == uid) {
        get_log();
      } else {
        return false;
      }
    },
    error: function(XmlHttpRequest, textStatus, errorThrown){
      console.log(XmlHttpRequest.responseText);
      alert("skipd数据读取错误！");
    }
  });
}
function reload_Soft_Center(){
  location.href = "/Module_Softcenter.asp";
}
function menu_hook(title, tab) {
  tabtitle[tabtitle.length - 1] = new Array("", "npc 内网穿透");
  tablink[tablink.length - 1] = new Array("", "Module_npc.asp");
}
function version_show(){
  // $.ajax({
  //   url: 'https://koolshare.ngrok.wang/npc/config.json.js',
  //   type: 'GET',
  //   dataType: 'jsonp',
  //   success: function(res) {
  //     if(typeof(res["version"]) != "undefined" && res["version"].length > 0) {
  //       if(res["version"] == db_npc["npc_version"]){
  //         $("#npc_version_show").html(" - " + res["version"]);
  //       }else if(res["version"] > db_npc["npc_version"]) {
  //         $("#npc_version_show").html("<font color=\"#66FF66\">【有新版本：" + res.version + "】</font>");
  //       }
  //     }
  //   }
  // });
}
function hook_event(){
  $(".popup_bar_bg_ks").click(
    function() {
      count_down = -1;
    });
  $(window).resize(function(){
    if($('.popup_bar_bg_ks').css("visibility") == "visible"){
      document.scrollingElement.scrollTop = 0;
      var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
      var log_h = E("loadingBarBlock").clientHeight;
      var log_w = E("loadingBarBlock").clientWidth;
      var log_h_offset = (page_h - log_h) / 2;
      var log_w_offset = (page_w - log_w) / 2 + 90;
      $('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
    }
  });
}
function showWBLoadingBar(){
  document.scrollingElement.scrollTop = 0;
  E("LoadingBar").style.visibility = "visible";
  E("loading_block_title").innerHTML = "【npc】日志";
  var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
  var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
  var log_h = E("loadingBarBlock").clientHeight;
  var log_w = E("loadingBarBlock").clientWidth;
  var log_h_offset = (page_h - log_h) / 2;
  var log_w_offset = (page_w - log_w) / 2 + 90;
  $('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
}
function hideWBLoadingBar(){
  E("LoadingBar").style.visibility = "hidden";
  E("ok_button").style.visibility = "hidden";
  if (refresh_flag == "1"){
    refreshpage();
  }
}
function count_down_close() {
  if (count_down == "0") {
    hideWBLoadingBar();
  }
  if (count_down < 0) {
    E("ok_button1").value = "手动关闭"
    return false;
  }
  E("ok_button1").value = "自动关闭（" + count_down + "）"
    --count_down;
  setTimeout("count_down_close();", 1000);
}
function get_log(action){
  E("ok_button").style.visibility = "hidden";
  showWBLoadingBar();
  $.ajax({
    url: '/_temp/npc_log.txt',
    type: 'GET',
    cache:false,
    dataType: 'text',
    success: function(response) {
      var retArea = E("log_content");
      if (response.search("XU6J03M6") != -1) {
        retArea.value = response.myReplace("XU6J03M6", " ");
        E("ok_button").style.visibility = "visible";
        retArea.scrollTop = retArea.scrollHeight;
        if(action == 1){
          count_down = -1;
          refresh_flag = 0;
        }else{
          count_down = 5;
          refresh_flag = 1;
        }
        count_down_close();
        return false;
      }
      setTimeout("get_log();", 300);
      retArea.value = response.myReplace("XU6J03M6", " ");
      retArea.scrollTop = retArea.scrollHeight;
    },
    error: function(xhr) {
      E("loading_block_title").innerHTML = "暂无日志信息 ...";
      E("log_content").value = "日志文件为空，请关闭本窗口！";
      E("ok_button").style.visibility = "hidden";
      return false;
    }
  });
}
</script>
</head>
<body onload="init();">
  <div id="TopBanner"></div>
  <div id="Loading" class="popup_bg"></div>
  <div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
    <table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
      <tr>
        <td height="100">
        <div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
        <div id="loading_block_spilt" style="margin:10px 0 10px 5px;" class="loading_block_spilt"></div>
        <div style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
          <textarea cols="50" rows="26" wrap="off" readonly="readonly" id="log_content" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
        </div>
        <div id="ok_button" class="apply_gen" style="background: #000;visibility:hidden;">
          <input id="ok_button1" class="button_gen" type="button" onclick="hideWBLoadingBar()" value="确定">
        </div>
        </td>
      </tr>
    </table>
  </div>
  <table class="content" align="center" cellpadding="0" cellspacing="0">
    <tr>
      <td width="17">&nbsp;</td>
      <td valign="top" width="202">
        <div id="mainMenu"></div>
        <div id="subMenu"></div>
      </td>
      <td valign="top">
        <div id="tabMenu" class="submenuBlock"></div>
        <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
          <tr>
            <td align="left" valign="top">
              <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
                <tr>
                  <td bgcolor="#4D595D" colspan="3" valign="top">
                    <div>&nbsp;</div>
                    <div class="formfonttitle">npc 内网穿透客户端<lable id="npc_version_show"><lable></div>
                    <div style="float:right; width:15px; height:25px;margin-top:-20px">
                      <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                    </div>
                    <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                    <div class="SimpleNote">
                      <span>
                        npc 内网穿透客户端，需要配合nps服务端使用
                      </span>
                    </div>
                    <div id="npc_main">
                      <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                        <tr id="switch_tr">
                          <th>
                            <label><a class="hintstyle" href="javascript:void(0);" onclick="openssHint(0)">开启npc</a></label>
                          </th>
                          <td colspan="2">
                            <div class="switch_field" style="display:table-cell;float: left;">
                              <label for="npc_enable">
                                <input id="npc_enable" class="switch" type="checkbox" style="display: none;">
                                <div class="switch_container" >
                                  <div class="switch_bar"></div>
                                  <div class="switch_circle transition_style">
                                    <div></div>
                                  </div>
                                </div>
                              </label>
                            </div>
                            <div style="float: right;margin-top:5px;margin-right:30px;">
                              <a type="button" href="https://github.com/cdwangtao/koolshare_npc" target="_blank" class="ks_btn" style="cursor: pointer;border:none;" >npc插件</a>
                              <a type="button" href="https://github.com/ehang-io/nps" target="_blank" class="ks_btn" style="cursor: pointer;border:none;" >npc项目</a>
                              <a type="button" href="https://ehang-io.github.io/nps/" target="_blank" class="ks_btn" style="cursor: pointer;margin-left:5px;border:none" >手册</a>
                              <a type="button" href="https://raw.githubusercontent.com/cdwangtao/koolshare_npc/master/Changelog.txt" target="_blank" class="ks_btn" style="cursor: pointer;margin-left:5px;border:none" >更新日志</a>
                              <a type="button" class="ks_btn" href="javascript:void(0);" onclick="get_log(1)" style="cursor: pointer;margin-left:5px;border:none">查看日志</a>
                            </div>
                          </td>
                        </tr>
                      </table>
                      <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top:8px;">
                        <thead>
                            <tr>
                            <td colspan="2">npc 相关设置</td>
                            </tr>
                          </thead>
                        <th style="width:25%;">运行状态</th>
                        <td>
                          <div id="npc_status"><i><span id="status">获取中...</span></i></div>
                        </td>
                        <tr>
                          <th width="20%"><a class="hintstyle" href="javascript:void(0);" onclick="openssHint(1)">服务端域名或IP</a></th>
                          <td>
                            <input type="text" class="input_ss_table" value="" id="npc_common_server_ip" name="npc_common_server_ip" maxlength="50" value="" placeholder=""/>
                          </td>
                        </tr>
                        <tr>
                          <th width="20%"><a class="hintstyle" href="javascript:void(0);" onclick="openssHint(2)">服务端端口</a></th>
                          <td>
                            <input type="text" class="input_ss_table" value="" id="npc_common_server_port" name="npc_common_server_port" maxlength="5" value="" placeholder=""/>
                          </td>
                        </tr>
                        <tr>
                          <th width="20%"><a class="hintstyle" href="javascript:void(0);" onclick="openssHint(3)">唯一验证密钥</a></th>
                          <td>
                            <input type="text" class="input_ss_table" value="" id="npc_common_vkey" name="npc_common_vkey" maxlength="50" value="" placeholder=""/>
                          </td>
                        </tr>
                      </table>
                    </div>
                    <div class="apply_gen">
                      <input class="button_gen" id="cmdBtn" onClick="save()" type="button" value="提交" />
                    </div>
                    <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                    <div class="SimpleNote">
                      <!--<span>* 注意事项：</span>
                      <li>1. 使用npc前确保你的路由器可以获得公网ip</li>
                      <li>2. 为了npc稳定运行，强烈建议使用虚拟内存</li>
                      <li>3. 上面所有内容都为必填项，请认真填写，不然无法提供穿透服务。</li>
                      <li>4. 每一个文字都可以点击查看相应的帮助信息。</li>-->
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <div id="footer"></div>
</body>
</html>