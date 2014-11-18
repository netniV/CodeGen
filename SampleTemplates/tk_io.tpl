<CODEGEN_FILENAME><Structure_Name>Io.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       tk_io.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: This template generates a Synergy function which performs
;//              file IO for a specific structure / file specification.
;//
;// Date:        19th March 2007
;//
;// Author:      Richard C. Morris, Synergex Professional Services Group
;//              http://www.synergex.com
;//
;//****************************************************************************
;//
;// Copyright (c) 2012, Synergex International, Inc.
;// All rights reserved.
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met:
;//
;// * Redistributions of source code must retain the above copyright notice,
;//   this list of conditions and the following disclaimer.
;//
;// * Redistributions in binary form must reproduce the above copyright notice,
;//   this list of conditions and the following disclaimer in the documentation
;//   and/or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;// POSSIBILITY OF SUCH DAMAGE.
;//
;;*****************************************************************************
;;
;; Routine:     <Structure_Name>Io
;;
;; Author:      <AUTHOR>
;;
;; Company:     <COMPANY>
;;
;;*****************************************************************************
;;
;; WARNING:     This code was generated by CodeGen. Any changes that you make
;;              to this file will be lost if the code is regenerated.
;;
;;*****************************************************************************

function <Structure_Name>Io ,^val

    ;Required arguments
    a_mode              ,n      ;Access type
    a_channel           ,n      ;Channel
    a_key               ,a      ;Key value
    a_keynum            ,n      ;Key number
    .include "<STRUCTURE_NOALIAS>" repository, group="<structure_name>"

    ;Optional arguments
    a_lock              ,n      ;If passed and TRUE, lock record
    a_partial           ,n      ;If passed and TRUE, do partial key reads
    a_error_state       ,n      ;If passed and true, errors displayed

    endparams

    .include "WND:tools.def"
    .include "RPSLIB:ddinfo.def"
    .include "CODEGEN_INC:structure_io.def"

    stack record ivars
        err                 ,i4     ;Error occurred / error number
        line                ,i4     ;Error line number
        keyno               ,i4     ;Key number
        keylen              ,i4     ;Key length
        lock                ,i4     ;Lock record?
        pos                 ,i4     ;Position in a string
    endrecord

    stack record avars
        errmsg              ,a45    ;Error message
        message             ,a80    ;User message
        keyval              ,a255   ;Hold original key
    endrecord

proc

    clear ^i(ivars), avars

    onerror fatal_io_error

    if ^passed(a_key)
    begin
        keyval = a_key
        if (^passed(a_partial)&&a_partial) then
            keylen = %trim(a_key)
        else
            keylen = ^size(a_key)
    end

    if ^passed(a_keynum) then
        keyno=a_keynum
    else
        keyno=D_PRIMKEY

    if (!^passed(a_key) && ^passed(<structure_name>))
    begin
        keyval = %keyval(a_channel,<structure_name>,keyno)
        if (^passed(a_partial)&&a_partial) then
            keylen = %trim(%keyval(a_channel,<structure_name>,keyno))
        else
        keylen = ^len(%keyval(a_channel,<structure_name>,keyno))
    end

    if (!^passed(a_lock)) then
        lock = Q_NO_LOCK
    else
        lock = Q_AUTO_LOCK

    repeat
    begin

        using a_mode select

        (IO_OPEN_INP),
        begin
            xcall u_open(a_channel,"i:i","<FILE_NAME>",,,err)
            if (err)
                call open_error
            exitloop
        end

        (IO_OPEN_UPD),
        begin
            xcall u_open(a_channel,"u:i","<FILE_NAME>",,,err)
            if (err)
                call open_error
            exitloop
        end

        (IO_FIND),
        begin
            find(a_channel,,keyval(1:keylen),KEYNUM:keyno)
            &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]
        end

        (IO_FIND_FIRST),
        begin
            find(a_channel,,^FIRST,KEYNUM:keyno)
            &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]
        end

        (IO_READ_FIRST),
        begin
            read(a_channel,<structure_name>,^FIRST,KEYNUM:keyno,LOCK:lock)
            &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]
        end

        (IO_READ),
        begin
            read(a_channel,<structure_name>,keyval(1:keylen),KEYNUM:keyno,LOCK:lock)
            &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]
        end

        (IO_READ_NEXT),
        begin
            reads(a_channel,<structure_name>,LOCK:lock)
            &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]
        end

        (IO_READ_PREV),
        begin
            reads(a_channel, <structure_name>,,REVERSE,LOCK:lock)
            &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]
        end

        (IO_READ_LAST),
        read(a_channel,<structure_name>,^LAST, KEYNUM:keyno,LOCK:lock)
        &   [$ERR_EOF=end_of_file,$ERR_LOCKED=record_locked,$ERR_KEYNOT=key_not_found]

        (IO_CREATE),
        begin
            ;Make sure zero decimals contain zeros not spaces
            <FIELD_LOOP>
            <IF DECIMAL>
            if (!<field_path>)
                clear <field_path>
            </IF>
            <IF DATE>
            if (!<field_path>)
                clear <field_path>
            </IF>
            <IF TIME>
            if (!<field_path>)
                clear <field_path>
            </IF>
            </FIELD_LOOP>
            store(a_channel,<structure_name>)
            &   [$ERR_NODUPS=duplicate_key]
        end

        (IO_DELETE),
        begin
            delete(a_channel)
            &   [$ERR_NOCURR=no_current_record]
        end

        (IO_UPDATE),
        begin
            write(a_channel,<structure_name>)
            &   [$ERR_NOCURR=no_current_record]
        end

        (IO_UNLOCK),
        begin
            unlock a_channel
            exitloop
        end

        (IO_CLOSE),
        begin
            if (a_channel)
            begin
                xcall u_close(a_channel)
                clear a_channel
            end
            exitloop
        end

        (),
            xcall u_msgbox('Invalid file access mode',D_MOK+D_MICONSTOP)

        endusing

        offerror

        if (!^passed(a_lock) || (^passed(a_lock) && !a_lock))
            if (a_channel && %chopen(a_channel))
                unlock a_channel

        freturn IO_OK

;-------------------------------------------------------------------------------

record_locked,

        if (^passed(a_error_state) && a_error_state) then
        begin
            using a_error_state select
            (D_DISPLAY_ERR, D_DISPLAY_LOCKERR, D_DISPLAY_LOCKERR+1),
            begin
                ;If error is record locked - display it - no question
                call wait_message
                nextloop
            end
            (D_NODISPLAY_LOCKERR, D_NODISPLAY_LOCKERR+1),
            begin
                ;Don't display lock error
                sleep 1
                nextloop    ;try again
            end
            (D_ASK_LOCKERR, D_ASK_LOCKERR+1),
            begin
                ;If error is record locked - ask to retry
                if (%u_msgbox('Record locked. Retry ?',D_MICONQUESTION+D_MYESNO)!=D_MIDYES)
                    freturn IO_LOCKED
                nextloop
            end
            (D_RETURN_LOCKERR, D_RETURN_LOCKERR+1),
            begin
                ;Return the locked error code
                freturn IO_LOCKED
            end
            endusing
        end
        else
        begin
            if (g_terminal) then
                call wait_message
            else
            begin
                sleep 1
                nextloop
            end
        end
    end

    if (!^passed(a_lock) || (^passed(a_lock) && a_lock))
        if (a_channel && %chopen(a_channel))
            unlock a_channel

    freturn IO_OK

;-------------------------------------------------------------------------------

wait_message,

    xcall u_beep
    xcall e_enter
    xcall e_sect('Record locked in <STRUCTURE_NAME>. Key '+%atrim(keyval),D_INFO,D_CLEAR,D_LEFT)
    xcall u_update
    sleep 1

    xcall e_sect('Retrying after record lock in <STRUCTURE_NAME>. Key '+%atrim(keyval),D_INFO,D_CLEAR,D_LEFT)
    xcall u_update
    sleep 1

    xcall e_exit

    return

;-------------------------------------------------------------------------------

end_of_file,

    unlock a_channel

    if (^passed(a_error_state) && (a_error_state==D_DISPLAY_ERR))
        xcall u_msgbox('Record not found - end of file.',D_MOK+D_MICONSTOP)

    freturn IO_EOF

;-------------------------------------------------------------------------------

key_not_found,

    unlock a_channel

    if (^passed(a_error_state) && (a_error_state==D_DISPLAY_ERR))
        xcall u_msgbox('Record not found',D_MOK+D_MICONSTOP)

    if (^passed(a_key))
        a_key = keyval

    freturn IO_NOT_FOUND

;-------------------------------------------------------------------------------

duplicate_key,

    unlock a_channel

    if (^passed(a_error_state) && (a_error_state==D_DISPLAY_ERR))
        xcall u_msgbox('Record already exists',D_MOK+D_MICONSTOP)

    freturn IO_DUP_KEY

;-------------------------------------------------------------------------------

no_current_record,

    unlock a_channel

    if (^passed(a_error_state) && (a_error_state==D_DISPLAY_ERR))
        xcall u_msgbox('No record was locked',D_MOK+D_MICONSTOP)

    freturn IO_NO_CUR_REC

;-------------------------------------------------------------------------------

fatal_io_error,

    if (a_channel && %chopen(a_channel))
        unlock a_channel

    offerror

    call get_error_text

    if (^passed(a_error_state) && (a_error_state==D_DISPLAY_ERR))
        xcall u_msgbox(%atrim(message),D_MOK+D_MICONSTOP)

    freturn IO_FATAL

;-------------------------------------------------------------------------------

open_error,

    if (^passed(a_error_state) && (a_error_state==D_DISPLAY_ERR))
        xcall u_msgbox('Failed to open file',D_MOK+D_MICONSTOP)

    freturn IO_FATAL

;-------------------------------------------------------------------------------

get_error_text,

    xcall error(err,line)
    xcall ertxt(err,errmsg)

    xcall s_bld(message,,'Error : %d, %a, at line : %d',err,errmsg,line)

    return

endfunction


