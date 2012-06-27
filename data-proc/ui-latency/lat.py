#!/usr/bin/env python

import sys
import re

def warn(msg): sys.stderr.write("warning:" + msg + "\n")

def err(msg):
    sys.stderr.write(msg + "\n")
    sys.exit(1)

def done(msg):
    sys.stderr.write(msg + "\n")
    sys.exit(0)

def extract_ts(line):
    ex1 = r'''<([0-9\.]*)>'''
    #ex1 = r'''<(.*)>'''
    m = re.search(ex1, line)
    if m:
        return float(m.group(1))
    else:
        err("no timestamp found in line" + line)


def extract_hist_ts(line):
    ex1 = r'''{([0-9\.]*)}'''
    m = re.search(ex1, line)
    if m:
        return float(m.group(1))
    else:
        err("no hist timestamp found in line" + line)


INVALID = -9999

ts_records = {}
is_init_ts_record = False

# True: add ok
# False: add fail

def try_add_lineno_record(k, lineno, is_dry_run):    # must be in increasing line order
    global is_init_ts_record

    if lineno == INVALID:
        return False

    if not is_init_ts_record:
        for key, v in keywords.iteritems():
            ts_records[key] = []
        is_init_ts_record = True

    if not ts_records.has_key(k):
        err("add_ts_record %s no found\n" %k)

    if (len(ts_records[k]) > 0 and ts_records[k][-1] >= lineno):
        return False
    else:
        if (not is_dry_run):
            ts_records[k].append(lineno)
        return True

def find_chkpt(line, checkpt):
    if line.find(keywords[checkpt]) == -1:
        return False;
    else:
        return True;

def header():
    sys.stderr.write("LINE APP_SEE_EVENT\t SF_BEFORE_SWAP_FB\t SF_AFTER_SWAP_FB\n")


# not including this_line
def find_chkpt_most_recent(lines, this_line, msg):
    count = len(lines)
    i = this_line - 1
    while (i >= 0):
        if (find_chkpt(lines[i], msg)):
            if (extract_ts(lines[i]) <= extract_ts(lines[this_line])):
                return i
        i -= 1
    return INVALID    # invalid

def find_chkpt_most_recent_verify(lines, this_line, tag, is_dry_run): # also check whether the ts is consumed
    line = find_chkpt_most_recent(lines, this_line, tag)
    if line == INVALID:
        raise Exception('no %s before line %d' %(tag, this_line+1))

    if try_add_lineno_record(tag, line, is_dry_run=is_dry_run) == False:
        last_line = ts_records[tag][-1]
        last_ts   = extract_ts(lines[last_line])
        this_ts   = extract_ts(lines[this_line])
        raise Exception('no recent %s before line %d, last is %d (%.2f ms ago)' %(tag, this_line+1, last_line+1, this_ts - last_ts))

    return line

# not including this_line
#
# when this_line == -1, search start from line 0, and return whatever the 1st found
def find_chkpt_next(lines, this_line, msg):
    count = len(lines)
    i = this_line + 1
    while (i < count):
        if (find_chkpt(lines[i], msg)):
            if (this_line == -1) or (extract_ts(lines[i]) >= extract_ts(lines[this_line])):
                return i
        i += 1
    return INVALID    # invalid

def find_chkpt_next_verify(lines, this_line, tag, is_dry_run):
    line = find_chkpt_next(lines, this_line, tag)

    if line == INVALID:
        raise Exception('no %s after line %d' %(tag, this_line+1))

    if try_add_lineno_record(tag, line, is_dry_run=is_dry_run) == False:
        raise Exception('no found line', tag)

    return line


keywords = {
"INPUT_EVENT_GEN"            : "ev hits user code",
"APP_SEE_EVENT"                : "ev hits user code",
"APP_BEFORE_DRAW_FRAME"         : "BEFORE GLSurfaceView DrawFrame",
"APP_AFTER_DRAW_FRAME"        : "AFTER GLSurfaceView DrawFrame",
"APP_BEFORE_SWAP_FRAME"        : "BEFORE GLSurfaceView swap frame",
"APP_AFTER_SWAP_FRAME"        : "AFTER GLSurfaceView swap frame",
"APP_QUEUE_FRAME"             : "SurfaceTextureClient::queueBuffer",
"SF_QUEUE_FRAME"             : "Layer::onFrameQueued",
"SF_BEFORE_SWAP_FB"             : "prepare to swap fb",
"SF_AFTER_SWAP_FB"             : "swap fb done",
}

if __name__ == "__main__":
    f=file(sys.argv[1])
    lines = f.readlines()
    count = len(lines)

    header()

    sf_before_swap_fb_line = 0
    while(sf_before_swap_fb_line < count):
        # for temporay results
        line_dict   = {}
        ts_dict     = {}
        last_ev_line   = INVALID

        try:
            sf_before_swap_fb_line      = find_chkpt_next_verify(lines, sf_before_swap_fb_line - 1, "SF_BEFORE_SWAP_FB", is_dry_run=False)
            last_ev_line                   = sf_before_swap_fb_line

            # look up in reverse order
            for tag in ["SF_QUEUE_FRAME", "APP_QUEUE_FRAME", "APP_BEFORE_SWAP_FRAME", \
                    "APP_AFTER_DRAW_FRAME", "APP_BEFORE_DRAW_FRAME", "APP_SEE_EVENT"]:
                last_ev_line = find_chkpt_most_recent_verify(lines, last_ev_line, tag, is_dry_run=True)

        except Exception as e:
            print e.args
            #warn("event chain not complete, skip")
            sf_before_swap_fb_line += 1 # get over the current swap_fb, move on
            continue

        # now, everything looks good. commit all ts to ts_records
        last_ev_line                   = sf_before_swap_fb_line
        for tag in ["SF_QUEUE_FRAME", "APP_QUEUE_FRAME", "APP_BEFORE_SWAP_FRAME", \
                "APP_AFTER_DRAW_FRAME", "APP_BEFORE_DRAW_FRAME", "APP_SEE_EVENT"]:
            line_dict[tag] = find_chkpt_most_recent_verify(lines, last_ev_line, tag, is_dry_run=False)
            last_ev_line = line_dict[tag]

        #swap_fb_ts = extract_ts(lines[sf_before_swap_fb_line])
        #queue_frame_ts = extract_ts(lines[sf_queue_frame_line])
        #event_ts   = extract_hist_ts(lines[last_i])

        #print last_i+1, j+1, k+1, "\t\t\t",
        #print event_ts, hit_app_ts, swap_fb_ts, swap_fb_done_ts,
        #print "\t\t\t", hit_app_ts - event_ts, swap_fb_ts - hit_app_ts, swap_fb_done_ts - swap_fb_ts
        for tag in ["APP_SEE_EVENT", "APP_BEFORE_DRAW_FRAME", "APP_AFTER_DRAW_FRAME", "APP_BEFORE_SWAP_FRAME",\
                    "APP_QUEUE_FRAME", "SF_QUEUE_FRAME"]:
            print line_dict[tag]+1,

        print sf_before_swap_fb_line+1

        sf_before_swap_fb_line += 1

