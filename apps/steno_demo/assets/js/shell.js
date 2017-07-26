import Terminal from "xterm";
import _ from "underscore";
import socket from "./socket";

var channel;
var term;

function connect() {
  console.log("Connecting to jobs:" + window.job_id);
  channel = socket.channel("jobs:" + window.job_id, {});
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });
}

var chunks = {};
var last = 0;

$(function() {
  if (!$('#xterm')) {
    console.log("no #xterm");
    return;
  }

  connect();

  channel.on("chunks", resp => {
    _.each(resp.chunks, cc => {
      if (cc.serial > last) {
        last = cc.serial;
      }

      cc.data = cc.data.replace(/\n/g, "\r\n");
      chunks[cc.serial] = cc;
    });

    term.reset();

    _.each(_.range(last), ii => {
      var cc = chunks[ii] || {};
      term.write(cc.data || "");
    });
  });

  term = new Terminal({
    cursorBlink: false,
    cols: 100,
    rows: 40,
  });
  term.open($('#xterm')[0], false);
  $(function() { term.reset(); });

  window.term = term;
});
