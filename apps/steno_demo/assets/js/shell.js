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

$(function() {
  if (!$('#xterm')) {
    console.log("no #xterm");
    return;
  }

  connect();

  channel.on("chunks", resp => {
    term.reset();
    _.each(resp.chunks, cc => {
      cc = cc.replace(/\n/g, "\r\n");
      term.write(cc);
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
