
if { [set __dut [anparams --dut]] == "" } {
    error "DUT not passed from the command line"
}

TestBed tb ePDG $__dut

if { [catch {tb init} result] } {
    error.an "Failed to initialize the test bed:\n$result"
}

# ==============================================================
set id        ePDG:section0:test0:C##01
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/16/2016
set pctComp   100
set summary   "Test verifies MCC can connect to SWM,PCRF & S6B/AAA server"
set descr     "
1.  Verify SWM server is listening
2.  Verify PCRF server is listening
3.  Verify S6b/AAA server is listening"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Verify SWM server is listening" {

        set out [dut exec "show service-construct interface aaa-interface-group diameter peer-status"]

        #if  [set status_ [cmd_out . values.SWM-SERVER-1:[tb _ swm.originHost].STATUS]] == "okay" 
        if { [set status_ [cmd_out . values.SWM-SERVER-1.STATUS]] == "okay" } {
            log.test "SWM Server is connected to ePDG; SWM-SERVER-1 STATUS is 'okay'"
        } else {
            error.an "SWM Server is not connected to ePDG; Expected SWM-SERVER-1 STATUS to be 'okay' but got '$status_'"
        }
    }
    
    runStep "Verify PCRF server is listening" {

        set out [dut exec "show service-construct interface aaa-interface-group diameter peer-status"]

        if { [set status_ [cmd_out . values.PCRF-1.STATUS]] == "okay" } {
            log.test "PCRF Server is connected to PGW; PCRF-1STATUS is 'okay'"
        } else {
            error.an "PCRF Server is not connected to PGW; Expected PCRF-1 STATUS to be 'okay' but got '$status_'"
        }
    }
    
    runStep "Verify S6b/AAA server is listening" {

        set out [dut exec "show service-construct interface aaa-interface-group diameter peer-status"]

        if { [set status_ [cmd_out . values.S6BDiameter.STATUS]] == "okay" } {
            log.test "S6b/AAA Server is connected to PGW; S6BDiameter STATUS is 'okay'"
        } else {
            error.an "S6b/AAA Server is not connected to PGW; Expected S6BDiameter STATUS to be 'okay' but got '$status_'"
        }
    }
    
    runStep "Verify PCRF-2 server is not listening" {
        
        pcrfsim2 stop
        sleep 5
        
        set out [dut exec "show service-construct interface aaa-interface-group diameter peer-status"]

        if { [set status_ [cmd_out . values.PCRF-2.STATUS]] == "initial" } {
            log.test "PCRF Server is connected to PGW; PCRF-1STATUS is 'initial'"
        } else {
            error.an "PCRF Server is not connected to PGW; Expected PCRF-1 STATUS to be 'initial' but got '$status_'"
        }
    }
    
} {
    # Cleanup
    catch {pcrfsim2 stop}
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80123
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/17/2016
set pctComp   100
set summary   "Test verifies ePDG session on MCC with DH14/x509 2048 byte certificate - AES256/SHA2-256"
set descr     "Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Check the IPSec status and verify the Security certificate for v6 session" {
        
        array set ipsec [ePDG:start_ipsecv6_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certike "AES_CBC_256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && [string match $certesp "AES_CBC_256/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA2_256_128" $out] && [regexp.an -all "AES_CBC_256/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES256/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate for v4 session" {
        
        array set ipsec [ePDG:start_ipsecv4_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certike "AES_CBC_256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && [string match $certesp "AES_CBC_256/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA2_256_128" $out] && [regexp.an -all "AES_CBC_256/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES256/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
} {
    # Cleanup    
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80249
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/20/2016
set pctComp   100
set summary   "This test verify ePDG session on MCC with DH14/x509 2048 byte certificate - AES192/SHA2-256"
set descr     "
1.  Change the Certificate type from AES-256 to AES-192 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from AES-256 to AES-192 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-sha256-modp2048!/' /etc/ipsec.conf"
       
        #ue exec "sed -i 's/#*esp=aes256-sha256-modp2048!/#esp=aes256-sha256-modp2048!/g' /etc/ipsec.conf"
        #ue exec "sed -i 's/#*esp=aes192-sha256-modp2048!/esp=aes192-sha256-modp2048!/g' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
    
    }
    
    runStep "Check the IPSec status and verify the Security certificate for v4 session" {

        array set ipsec [ePDG:start_ipsecv4_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES192/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate for v6 session" {
        
        array set ipsec [ePDG:start_ipsecv6_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp
        
        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES192/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C341213
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   7/01/2016
set pctComp   100
set summary   "This test verify ePDG session on MCC with DH14/x509 2048 byte certificate - AES128-CTR/SHA2-256"
set descr     "
1.  Change the Certificate type from AES-256 to AES128-CTR in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from AES-256 to AES128-CTR in ipsec.conf file on UE" {
       
	    set ptrn "AES_CTR_128/HMAC_SHA2_256_128,"
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128ctr-sha256-modp2048!/' /etc/ipsec.conf"		
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate for v4 session" {
       
        array set ipsec [ePDG:start_ipsecv4_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp
        
        set out2 [ ue exec "ipsec statusall" ]
       #[string match $certike "AES_CTR_128/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && 
        if { [string match $certesp "AES_CTR_128/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an "AES_CTR_128/HMAC_SHA2_256_128," $out2] } {
			log.test "x509 2048 byte certificate - AES128-CTR/SHA2-256 Found"
		} else {
			error.an "No Matching Encryption algorithm found for IPSec session"
		}
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate for v6 session" {
       
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"
                
        array set ipsec [ePDG:start_ipsecv6_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp
        
        set out2 [ ue exec "ipsec statusall" ]
       
        if { [string match $certesp "AES_CTR_128/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an "AES_CTR_128/HMAC_SHA2_256_128," $out2] } {
			log.test "x509 2048 byte certificate - AES128-CTR/SHA2-256 Found"
		} else {
			error.an "No Matching Encryption algorithm found for IPSec session"
		}
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C341229
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/17/2016
set pctComp   100
set summary   "This test verify ePDG session on MCC with DH14/x509 2048 byte certificate - AES-XCBC for PRF"
set descr     "Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
	
    runStep "Check the IPSec status and verify the Security certificate for v4 session" {
        
		array set ipsec [ePDG:start_ipsecv4_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\""]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - cert
        
        set out2 [ ue exec "ipsec statusall" ]
		
        if {[regexp.an "IKE proposal: $cert" $out2]} {
			log.test "x509 2048 byte certificate - AES-XCBC for PRF Found"
		} else {
			error.an "No Matching Encryption algorithm found for IPSec session"
		}
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate for v6 session" {
        
        array set ipsec [ePDG:start_ipsecv6_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\""]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - cert
        
        set out2 [ ue exec "ipsec statusall" ]
		
        if {[regexp.an "IKE proposal: $cert" $out2]} {
			log.test "x509 2048 byte certificate - AES-XCBC for PRF Found"
		} else {
			error.an "No Matching Encryption algorithm found for IPSec session"
		}        
        
    }
    
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80140
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/16/2016
set pctComp   100
set summary   "This test checks the diameter endpoint statistics"
set descr     "
1.  Clear any previous ipsec session and diameter Statistics
2.  Start a new IPSec session and verify the statistics"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear any previous ipsec session and diameter Statistics" {
	
        ue exec "ipsec restart"
        #sleep 5
        
        dut exec "service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type SWM SWM-SERVER-1 swm-server.carrier.net clear"
        dut exec "network-context S2B-PGW networkcontext-statistics S2B-PGW clear"
        dut exec "network-context S2B-EPDG networkcontext-statistics S2B-EPDG clear"
        
    }
    
    runStep "Start a new IPSec session and verify the statistics" {

        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        sleep 10
    
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type SWM SWM-SERVER-1"

        if { [set status1 [cmd_out . values.num-diameter-sessions]] == 1} {
            log.test "Only One Diameter session is present"
        } else {
            error.an "$status1 Diameter sessions are present; Expected is One; Clear the log and try again"
        }
		#  show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type num-str-attempted == show subscriber pdn-session 2148565056 downlink-green-packets ??
		if { [set strAttempted [cmd_out . values.num-str-attempted]] == 0 && [set strSuccess [cmd_out . values.num-str-success]] == 0 } {
            log.test "No. of num-str-attempted ($strAttempted) are equal to No. of num-str-success ($strSuccess) and are equal to 0 "
        } else {
            error.an "No. of num-str-attempted ($strAttempted) are not equal to No. of num-str-success ($strSuccess) ; Expected is both shpuld equal and 0"
        }
		
		dut exec "show service-construct interface aaa-interface-group diameter peer-stats"
		
		if { [set NUMINREQUEST [cmd_out . values.SWM-SERVER-1.NUMINREQUEST]] == [set NUMOUTRESPONSE [cmd_out . values.SWM-SERVER-1.NUMOUTRESPONSE]] } {
            log.test "No. of num-in-requests are equal to No. of num-out-responses"
        } else {
            error.an "No. of num-in-requests ($NUMINREQUEST) are not equal to No. of num-out-responses ($NUMOUTRESPONSE)"
        }
		
		if { [set NUMINRESPONSE [cmd_out . values.SWM-SERVER-1.NUMINRESPONSE]] == [set NUMOUTREQUEST [cmd_out . values.SWM-SERVER-1.NUMOUTREQUEST]] } {
            log.test "No. of num-out-requests are equal to No. of num-in-responses"
        } else {
            error.an "No. of num-out-requests ($NUMINRESPONSE) are not equal to No. of num-in-responses ($NUMOUTREQUEST)"
        }
		
	}
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80136
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/17/2016
set pctComp   100
set summary   "This test verifies that PGW address is configured on ePDG - HSS doesn't send PGW address"
set descr     "
1.  Start the IPSec session and find the Session ID
2.  Verify PGW Allocation type"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the IPSec session and find the Session ID" {
        
        array set ipsec [ePDG:start_ipsecv6_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { ![string is integer -strict [set n1 [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $n1"
        }
        
    }
    
    runStep "Verify PGW Allocation type" {    
        
		set out2 [ dut exec "show subscriber pdn-session $n1 pgw-ip-address-from-AAA" ]
		
        set out3 [ dut exec "show subscriber pdn-session $n1 pdngw-allocation-type" ]
        
        if {$out2 == {pgw-ip-address-from-AAA ""}} {
            if {$out3 == "pdngw-allocation-type not-sent-by-aaa"} {
                log.test "PGW address configured on ePDG - HSS doesn't send PGW address"
            } else {
                error.an "PGW IP address allocation type is different"
            }
        } else { 
            error.an "'Check PGW IP address from AAA' Field"
        }
    }
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80145
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Visitor PLMNID session"               	
set descr     "
1.  Configure allowed-plmnid as any
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as any" {

        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1 plmnid 456123; commit"  
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
            log.test "allowed-plmnid is configure as any"
        } else {
            error.an "Unable to configure allowed-plmnid as any"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "visiting"] == 1 } {
            log.test "Subscriber is in VPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: visiting"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80137
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/17/2016
set pctComp   100
set summary   "This test carries out the PGW IP address lookup via DNS based on visitor plmnid session"
set descr     "
1.  Start the session and verify UE receives 2 IPv4 and 2 IPvv6 DNS Addresses
2.  Verify the session is up on MCC and find the Session ID
3.  Find the DNS IP addresses configured on MCC
4.  Verify that the DNS IP addresses configured on MCC and the ones that are retrived from UE are same
5.  Verify if DNS lookup is based on visitor plmnid session"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and verify if UE receives 2 IPv4 and 2 IPv6 DNS Addresses" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
	
		if { [regexp.an {installing DNS server ([0-9.]+) via resolvconf\sinstalling DNS server ([0-9.]+) via resolvconf\sinstalling DNS server ([0-9:a-z]+) via resolvconf\sinstalling DNS server ([0-9:a-z]+) via resolvconf} $ipsec(ipsecinfo) - uev4dnsIp1 uev4dnsIp2 uev6dnsIp1 uev6dnsIp2] } {
            log.test "Found DNS IPv4 and IPv6 addresses on UE: $uev4dnsIp1 $uev4dnsIp2 $uev6dnsIp1 $uev6dnsIp2"
        } else {
            error.an "Failed to DNS IPs"
        }
				
    }
    
    runStep "Verify the session is up on MCC and find the Session ID" {
        
        set out [dut exec "show subscriber summary gateway-type epdg"]
		
		if { ![string is integer -strict [set n1 [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $n1"
        }
        
    }
    
    runStep "Find the DNS IP addresses configured on MCC" {
		
        set out [dut exec "show running-config zone default gateway apn dns-resolution-for-pgw-selection true"]
       
       if { [regexp.an -all -lineanchor {dns-server-configuration primary-ipv4-address ([0-9.]+)} $out - dnspriIpv4] } {
            log.test "Found 1st DNS IPv4 Address: $dnspriIpv4"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
       
        if { [regexp.an -all -lineanchor {dns-server-configuration secondary-ipv4-address ([0-9.]+)} $out - dnssecIpv4] } {
            log.test "Found 2nd DNS IPv4 Address: $dnssecIpv4"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
        if { [regexp.an -all -lineanchor {dns-server-configuration primary-ipv6-address ([0-9:a-z]+)} $out - dnspriIpv6] } {
            log.test "Found 1st DNS IPv6 Address: $dnspriIpv6"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
        if { [regexp.an -all -lineanchor {dns-server-configuration secondary-ipv6-address ([0-9:a-z]+)} $out - dnssecIpv6] } {
            log.test "Found 2nd DNS IPv6 Address: $dnssecIpv6"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
    }
    
    runStep "Verify that the DNS IP addresses configured on MCC and the ones that are retrived from UE are same" {
        
        if { $dnspriIpv4 == $uev4dnsIp1 } {
                if {$dnssecIpv4 == $uev4dnsIp2} {
                log.test "Primary and Secondary DNS IPv4 Addresses on UE and MCC matched"
            } else {
                error.an "Secondary DNS IP Address on UE($uev4dnsIp2) does not match with DNS IP Address on MCC ($dnssecIpv4)"
                }
        } else {
            error.an "Primary DNS IP Address on UE($uev4dnsIp1) does not match with DNS IP Address on MCC ($dnspriIpv4)"
        }
        
        if { $dnspriIpv6 == $uev6dnsIp1 } {
                if {$dnssecIpv6 == $uev6dnsIp2} {
                log.test "Primary and Secondary DNS IPv6 Addresses on UE and MCC matched"
            } else {
                error.an "Secondary DNS IP Address on UE($uev6dnsIp2) does not match with DNS IP Address on MCC ($dnssecIpv6)"
                }
        } else {
            error.an "Primary DNS IP Address on UE($uev6dnsIp1) does not match with DNS IP Address on MCC ($dnspriIpv6)"
        }
        
    }
    
    runStep "Verify if DNS lookup is based on visitor plmnid session" {
		
		
		set out2 [ dut exec "show subscriber pdn-session $n1 pgw-used-for-session" ]
		set out3 [ dut exec "show subscriber pdn-session $n1 plmn-for-pgw-dns" ]
		set l1 [string length $out3]
		set n2 [string range $out3 17 [expr {$l1-1}]]
		#The expression below verifies that DNS ID is a valid integer & not a blank space or zero
        set n3 [expr {0/$n2}] 
		
        if {$out2 == "pgw-used-for-session configured"} {
            if {$out3 == "plmn-for-pgw-dns $n2"} {
            	log.test "PGW is configured for the session and plmnid for PGW DNS Lookup is $n2"
			} else {
            	error.an "PGW is configured for the session and plmnid for PGW DNS Lookup is Invalid (Either 0 or Null)"
            }
		} else { 
            error.an "PGW is not configured for the session"
		}
    }
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226545:C226544
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/17/2016
set pctComp   100
set summary   "This test verify if UE is able to get both IPv4 and IPv6 addresses for a single PDN (dual stack) - data path on both stacks"
set descr     "
1.  Start the session and verify if UE receives both IPv4 and IPv6 Addresses
2.  Verify id ip assresses are shown on particular interface as primary with global scope"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and verify if UE receives both IPv4 and IPv6 Addresses" {
        
        array set ipsec [ePDG:start_ipsec_session]        
        
        if { [regexp.an {installing new virtual IP ([0-9.]+)\sinstalling new virtual IP ([0-9:a-z]+)} $ipsec(ipsecinfo) - ueIpv4 ueIpv6] } {
            log.test "Found new virtual IPv4 and IPv6: $ueIpv4 $ueIpv6"
        } else {
            error.an "Failed to retrieve new virtual IPs"
        }
        
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping6_os $ueIpv6
        ePDG:ue_ping6_os2 $ueIpv6
        ePDG:ue_tcp6_os $ueIpv6
        
    }
    
    runStep "Verify id ip assresses are shown on particular interface as primary with global scope" {
        
        set out [ ue exec "ip -o addr show up primary scope global" ]
		
        if { [regexp "$ueIpv4" $out] } {
            log.test "IPv4 address reported by UE"
        } else {
            error.an "UE does not report the new IPv4 ($ueIpv4) as active"
        }
        
        if { [regexp "$ueIpv6" $out] } {
            log.test "IPv6 address reported by UE"
        } else {
            error.an "UE does not report the new IPv6 ($ueIpv6) as active"
        }
    }
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226542
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/27/2016
set pctComp   100
set summary   "This test verify that UE downlink IPsec data packets has configured DSCP marking on ePDG"
set descr     "
1.  Capture the packets on SWU interface and start the session
2.  Filter out ESP packets and verify the DSCP filed and codepoint"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Capture the packets on SWU interface and start the session" {
        
        #pcrfsim2 stop
	
		dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 20000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        array set ipsec [ePDG:start_ipsecv6_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
		
		sleep 2
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Filter out ESP packets and verify the DSCP filed as well as codepoint" {
		
        tshark exec "tshark -r /tmp/umakant -Y 'esp'"
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V4 ip-address"]        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - epdg_swu_lbv4
        
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'esp and ip.src==$epdg_swu_lbv4 and ip.dst==[tb _ ue.ip]' | sed -n '1p' | awk  '{print \$1}'"]
		set out2 [ePDG:store_last_line $out1]
        
		set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Initiator: Responder' -e 'Differentiated Services Codepoint:'"]
        set dscp 11
        set dscp_hex "10"
        set dscp_val "A"

        ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
        
	}
} {
    # Cleanup
    #pcrfsim2 init
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226543
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/27/2016
set pctComp   100
set summary   "This test verify that UE s2b data packets has configured DSCP marking"
set descr     "
1.  Capture the packets on S2B interface and Start the v4 and v6 session
2.  Filter out IPv4 GTP and ICMP packets and verify the DSCP filed as well as codepoint
3.  Filter out IPv4 GTP and TCP packets and verify the DSCP filed as well as codepoint
4.  Filter out IPv6 GTP and ICMP packets and verify the DSCP filed as well as codepoint
5.  Filter out IPv6 GTP and TCP packets and verify the DSCP filed as well as codepoint"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Capture the packets on S2B interface and start the session" {
        
        #pcrfsim2 stop
	
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        array set ipsec [ePDG:start_ipsecv6_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
		
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Filter out IPv4 GTP and ICMP packets and verify the DSCP filed as well as codepoint" {
		
        tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmp'"
        
        for {set i 0} {$i < 2} {incr i} {
            
            if { $i == 0 } {
                set ip1 [tb _ os.ip]
                set ip2 $ipsec(ueIp4)
            } else {
                set ip1 $ipsec(ueIp4)
                set ip2 [tb _ os.ip]                
            }
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmp and ip.src==$ip1 and ip.dst==$ip2' | awk '{print \$1}' | sed -n '1p'"]
            set out2 [ePDG:store_last_line $out1]
            
            set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Codepoint:' | sed -n '1p'"]        
            set dscp 11
            set dscp_hex "10"
            set dscp_val "A"
            
            ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
            
        }
        
    }
    
    runStep "Filter out IPv4 GTP and TCP packets and verify the DSCP filed as well as codepoint" {
        
        for {set i 0} {$i < 2} {incr i} {
            
            if { $i == 0 } {
                set ip1 [tb _ os.ip]
                set ip2 $ipsec(ueIp4)
            } else {
                set ip1 $ipsec(ueIp4)
                set ip2 [tb _ os.ip]                
            }
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and tcp and ip.src==$ip1 and ip.dst==$ip2' | awk '{print \$1}' | sed -n '1p'"]
            set out2 [ePDG:store_last_line $out1]
            
            set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Codepoint:' | sed -n '1p'"]        
            set dscp 23
            set dscp_hex "22"
            set dscp_val "16"
            
            ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
            
        }
        
    }
    
    runStep "Filter out IPv6 GTP and ICMP packets and verify the DSCP filed as well as codepoint" {
        
        for {set i 0} {$i < 2} {incr i} {
            
            if { $i == 0 } {
                set ip1 [tb _ os.ipv6]
                set ip2 $ipsec(ueIp6)
            } else {
                set ip1 $ipsec(ueIp6)
                set ip2 [tb _ os.ipv6]                
            }
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmpv6 and ipv6.src==$ip1 and ipv6.dst==$ip2' | awk '{print \$1}' | sed -n '1p'"]
            set out2 [ePDG:store_last_line $out1]
            
            set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Codepoint:' | sed -n '1p'"]        
            set dscp 11
            set dscp_hex "10"
            set dscp_val "A"
            
            ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
            
        }
        
    }
    
    runStep "Filter out IPv6 GTP and TCP packets and verify the DSCP filed as well as codepoint" {
        
        for {set i 0} {$i < 2} {incr i} {
            
            if { $i == 0 } {
                set ip1 [tb _ os.ipv6]
                set ip2 $ipsec(ueIp6)
            } else {
                set ip1 $ipsec(ueIp6)
                set ip2 [tb _ os.ipv6]                
            }
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and tcp and ipv6.src==$ip1 and ipv6.dst==$ip2' | awk '{print \$1}' | sed -n '1p'"]
            set out2 [ePDG:store_last_line $out1]
            
            set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Codepoint:' | sed -n '1p'"]        
            set dscp 23
            set dscp_hex "22"
            set dscp_val "16"
            
            ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
            
        }
        
    }
	
} {
    # Cleanup
    #pcrfsim2 init
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80139
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/28/2016
set pctComp   100
set summary   "This test checks the ePDG Gateway statistics"
set descr     "
1.  Clear the ePDG call performance Statistics and bring up the new session
2.  Check if only 1 bearer and only 1 session is present/active
3.  Verify the ePDG call-performance statistics"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear the ePDG call performance Statistics and bring up the new session" {
	
        dut exec "zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber] clear"
		
		array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        sleep 2
        
    }
    
    runStep "Check if only 1 bearer and only 1 session is present/active" {
        
		sleep 10
        set out [ dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1" ]
        		
		if { [set status1 [cmd_out . values.current-sessions]] == 1} {
            log.test "One session is present"
        } else {
            error.an "$status1 sessions are present; Expected is One; Clear the log and try again"
        }
        
        if { [set status1 [cmd_out . values.active-sessions]] == 1} {
            log.test "One session is Active"
        } else {
            error.an "$status1 sessions are active; Expected is One; Clear the log and try again"
        }
        
        if { [set status1 [cmd_out . values.bearers]] == 3} {
            log.test "Three Bearers are present"
        } else {
            error.an "$status1 Bearers are present; Expected are Three; Clear the log and try again"
        }
        
    }
        
    runStep "Verify the ePDG call-performance statistics" {
        
        if { [set status1 [cmd_out . values.create-session-attempts]] == [set status2 [cmd_out . values.create-session-accepts]]} {
            log.test "All the attempted sessions are accepted"
        } else {
            error.an "No. of session-attempts ($status1) are not equal to No. of session-accepts ($status2) ; Expected is both shpuld be equal"
        }
        
        if { [set status1 [cmd_out . values.eap-attempts-sent-to-aaa-server]] == [set status2 [cmd_out . values.eap-successes-received-from-aaa-server]]} {
            log.test "All the requests received and processed by AAA server successfully"
        } else {
            error.an "No. of eap-attempts ($status1) are not equal to No. of eap-success ($status2) ; Expected is both shpuld be equal"
        }
		
		
	}
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
} 

# ==============================================================
set id        ePDG:section1:EPDG:C80138
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/29/2016
set pctComp   100
set summary   "This test checks the Security statistics"
set descr     "
1.  Start the session and check if only 1 Session/Tunnel/Instant is active
2.  Count the incoming and outgoing packets at SWU interface
3.  Ping Origin Server and verify if outgoing packets count increases by same number as no. of ping packets"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and check if only 1 Session/Tunnel/Instant is active" {
	
        array set ipsec [ePDG:start_ipsecv6_session]
        
        dut exec "show security service-status"
        
        if { [set status1 [cmd_out . values.SWU.OPERATIONALSTATUS]] == "up"} {
            log.test "SWU Interface is up and running"
        } else {
            error.an "SWU Interface is $status1 ; Expected is \"up\" ; Check the configuration"
        }
        
        if { [set status1 [cmd_out . values.SWU.CURRENTIKETUNNELS]] == [set status2 [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] && [set status3 [cmd_out . values.SWU.NUMBEROFACTIVEINSTANCES]] == 1 && $status2 == $status3} {
            log.test "One Session/Tunnel/Instant is active"
        } else {
            error.an "No. of IKE Tunnels ($status1) , No. of IPSec Tunnels ($status2) and No. of Active Instances ($status3) are not Equal ; Expected to be all Equal to 1"
        }
        
    }
    
    runStep "Count the incoming and outgoing packets at SWU interface" {
        
		sleep 60
        dut exec "show security statistics tunnel SWU"
        
        set swuInPackets [cmd_out . values.SWU.INPACKETS]
        set swuOutPackets [cmd_out . values.SWU.OUTPACKETS]
        
    }
    
    runStep "Ping Origin Server and verify if outgoing packets count increases by same number as no. of ping packets" {
        
        ePDG:ue_ping6_os $ipsec(ueIp6)
        
        dut exec "show security statistics tunnel SWU"
        
        if { [set status1 [cmd_out . values.SWU.INPACKETS]] == [expr $swuInPackets + 5] && [set status2 [cmd_out . values.SWU.OUTPACKETS]] == [expr $swuOutPackets + 5] } {
            log.test "Packet Statistics verified after Data Transmission"
        } else {
            error.an "No. of in packets are ($status1) ; Expected is 5. No. of out packets are ($status2)"
        }
		
	}
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226541
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/27/2016
set pctComp   100
set summary   "This test verify that data packets has configured DSCP marking on PGW GI Interface"
set descr     "
1.  Capture the packets on GI interface and Start the v4 and v6 session
2.  Filter out IPv4 ICMP packets and verify the DSCP filed as well as codepoint
3.  Filter out IPv4 TCP packets and verify the DSCP filed as well as codepoint
4.  Filter out IPv6 ICMP packets and verify the DSCP filed as well as codepoint
5.  Filter out IPv6 TCP packets and verify the DSCP filed as well as codepoint"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Capture the packets on GI interface and Start the v4 and v6 session" {
        
        #pcrfsim2 stop
	
		dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        #ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        array set ipsec [ePDG:start_ipsecv6_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        #ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Filter out IPv4 ICMP packets and verify the DSCP filed as well as codepoint" {
		
        tshark exec "tshark -r /tmp/umakant -Y 'tcp and icmp'"        
       
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'icmp and ip.src==$ipsec(ueIp4) and ip.dst==[tb _ os.ip]' | awk '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
        
        set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Codepoint:' | sed -n '1p'"]        
        set dscp 11
        set dscp_hex "10"
        set dscp_val "A"
        
        ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
            
    }
    
    runStep "Filter out IPv4 TCP packets and verify the DSCP filed as well as codepoint" {
       
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'tcp and ip.src==$ipsec(ueIp4) and ip.dst==[tb _ os.ip]' | awk '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
        
        set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Codepoint:' | sed -n '1p'"]        
        set dscp 23
        set dscp_hex "22"
        set dscp_val "16"
        
        ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
           
    }
    
    runStep "Filter out IPv6 ICMP packets and verify the DSCP filed as well as codepoint" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'icmpv6 and ipv6.src==$ipsec(ueIp6) and ipv6.dst==[tb _ os.ipv6]' | awk '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
        
        set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Field:' | sed -n '1p'"]        
        set dscp 11
        set dscp_hex "10"
        set dscp_val "A"
        
        ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val

    }
    
    runStep "Filter out IPv6 TCP packets and verify the DSCP filed as well as codepoint" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'tcp and ipv6.src==$ipsec(ueIp6) and ipv6.dst==[tb _ os.ipv6]' | awk '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
        
        set dscp_info [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'Differentiated Services Field:' | sed -n '1p'"]        
        set dscp 23
        set dscp_hex "22"
        set dscp_val "16"
        
        ePDG:verify_dscp_field_and_codepoint dscp $dscp dscp_hex $dscp_hex dscp_info $dscp_info dscp_val $dscp_val
        
    }
    
} {
    # Cleanup
    #pcrfsim2 init
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226547
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/29/2016
set pctComp   100
set summary   "This test verify S2b APCO IE with DNS Request Support"
set descr     "
1.  Start the session and capture the packets on S2B interface
2.  Check if IE receives 2 v4 and 2 v6 DNS IP Addresses
3.  Check if session is active on MCC and find the Tunnel endpoint IP addresses
4.  Filter out gtp packets with source and dest. IP addresses as tunnel endpoint IP addresses
5.  Look for APCO IE field and DNS IP addresses and verify the corresponding IDs in Request packet
6.  Look for DNS IP addresses and verify the corresponding IDs in Response packet
7.  Verify that DNS IP address on UE matches with the one allocated by MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and capture the packets on S2B interface" {
	
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Check if UE receives 2 v4 and 2 v6 DNS IP Addresses" {
        
        if { [regexp.an {installing DNS server ([0-9.]+) via resolvconf\sinstalling DNS server ([0-9.]+) via resolvconf\sinstalling DNS server ([0-9:a-z]+) via resolvconf\sinstalling DNS server ([0-9:a-z]+) via resolvconf} $ipsec(ipsecinfo) - uev4dnsIp1 uev4dnsIp2 uev6dnsIp1 uev6dnsIp2] } {
            log.test "Found DNS IPv4 and IPv6 addresses on UE: $uev4dnsIp1 $uev4dnsIp2 $uev6dnsIp1 $uev6dnsIp2"
        } else {
            error.an "Failed to retrieve DNS IPs"
        }
		
    }
    
    runStep "Check if session is active on MCC and find the Tunnel endpoint IP addresses" {
    
		dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Filter out gtp packets with source and dest. IP addresses as tunnel endpoint IP addresses" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		#set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.addr==$ip1 && ipv6.addr==$ip2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
		set out2 [ePDG:store_last_line $out1]
		
		set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IE Type: Additional Protocol Configuration Options (APCO)' | sed -n '1p'"]
        
    }
    
    runStep "Look for APCO IE field and DNS IP addresses and verify the corresponding IDs in Request packet" {
		
		if { [regexp.an "<field name=\"gtpv2.ie_type\"" $out] } {
            log.test "APCO IE Found"
        } else {
            error.an "Unable to find find APCO IE"
        }
		
		if { [regexp.an "(163)\"" $out] } {
            log.test "APCO IE Type Verified"
        } else {
            error.an "Failed to verify APCO IE Type; Expected is 163"
        }
		
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: DNS Server IPv4 Address Request (0x000d)' | sed -n '1p'"]
		
		if { [regexp.an "(0x000d)" $out] } {
            log.test "DNS IPv4 Request ID Verified"
        } else {
            error.an "Failed to verify DNS IPv4 Request ID ; Expected is 0x000d"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: DNS Server IPv6 Address Request (0x0003)' | sed -n '1p'"]
		
		if { [regexp.an "(0x0003)" $out] } {
            log.test "DNS IPv6 Request ID Verified"
        } else {
            error.an "Failed to verify DNS IPv6 Request ID ; Expected is 0x0003"
        }
        
    }
    
    runStep "Look for DNS IP addresses and verify the corresponding IDs in Response packet" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		#set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.addr==$ip2 && ipv6.addr==$ip1' | grep -e \"Create Session Response\" | awk  '{print \$1}' | sed -n '1p'"]
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Response\" | awk  '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
        
		set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e ' showname=\"Protocol or Container ID: DNS Server IPv4 Address (0x000d)' | sed -n '1p'"]
        
        if { [regexp.an "(0x000d)" $out] } {
            log.test "DNS IPv4 Response ID Verified"
        } else {
            error.an "Failed to verify DNS IPv4 Response ID ; Expected is 0x000d"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: DNS Server IPv6 Address (0x0003)' | sed -n '1p'"]
		
		if { [regexp.an "(0x0003)" $out] } {
            log.test "DNS IPv6 Response ID Verified"
        } else {
            error.an "Failed to verify DNS IPv6 Response ID ; Expected is 0x0003"
        }
        
    }
        
    runStep "Verify that DNS IP address on UE matches with the one allocated by MCC" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv4: $uev4dnsIp1 ($uev4dnsIp1)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev4dnsIp1\"" $out] } {
            log.test "DNS Primary IPv4 Address Verified"
        } else {
            error.an "Failed to verify DNS Primary IPv4 Address ; Expected is $uev4dnsIp1"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv4: $uev4dnsIp2 ($uev4dnsIp2)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev4dnsIp2\"" $out] } {
            log.test "DNS Secondary IPv4 Address Verified"
        } else {
            error.an "Failed to verify DNS Secondary IPv4 Address ; Expected is $uev4dnsIp2"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv6: $uev6dnsIp1 ($uev6dnsIp1)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev6dnsIp1\"" $out] } {
            log.test "DNS Primary IPv6 Address Verified"
        } else {
            error.an "Failed to verify DNS Primary IPv6 Address ; Expected is $uev6dnsIp1"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv6: $uev6dnsIp2 ($uev6dnsIp2)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev6dnsIp2\"" $out] } {
            log.test "DNS Secondary IPv6 Address Verified"
        } else {
            error.an "Failed to verify DNS Secondary IPv6 Address ; Expected is $uev6dnsIp2"
        }
        
                
	}
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226548
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   7/01/2016
set pctComp   100
set summary   "This test verify S2b APCO IE with P-CSCF Request Support"
set descr     "
1.  Start the session and capture the packets on S2B interface
2.  Check if UE receives 2 v4 and 2 v6 P-CSCF IP Addresses
3.  Check if session is active on MCC and find the Tunnel endpoint IP addresses
4.  Filter out gtp packets with source and dest. IP addresses as tunnel endpoint IP addresses
5.  Look for APCO IE field and P-CSCF IP addresses and verify the corresponding IDs in Request packet
6.  Look for P-CSCF IP addresses and verify the corresponding IDs in Response packet
7.  Verify that P-CSCF IP address on UE matches with the one allocated by MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and capture the packets on S2B interface" {
	
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
       		
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Check if UE receives 2 v4 and 2 v6 P-CSCF IP Addresses" {
        
        if { [regexp.an {received P-CSCF server IP ([0-9.]+)\sreceived P-CSCF server IP ([0-9.]+)\sreceived P-CSCF server IP ([0-9:a-z]+)\sreceived P-CSCF server IP ([0-9:a-z]+)} $ipsec(ipsecinfo) - uev4pcscfIp1 uev4pcscfIp2 uev6pcscfIp1 uev6pcscfIp2] } {
            log.test "Found P-CSCF IPv4 and IPv6 addresses: $uev4pcscfIp1 $uev4pcscfIp2 $uev6pcscfIp1 $uev6pcscfIp2]"
        } else {
            error.an "Failed to retrieve P-CSCF IPs"
        }
		
    }
    
    runStep "Check if session is active on MCC and find the Tunnel endpoint IP addresses" {
        
		dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Filter out gtp packets with source and dest. IP addresses as tunnel endpoint IP addresses" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		#set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.addr==$ip1 && ipv6.addr==$ip2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
		set out2 [ePDG:store_last_line $out1]
		
		set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IE Type: Additional Protocol Configuration Options (APCO)' | sed -n '1p'"]
        
    }
    
    runStep "Look for APCO IE field and P-CSCF IP addresses and verify the corresponding IDs in Request packet" {
		
		if { [regexp.an "<field name=\"gtpv2.ie_type\"" $out] } {
            log.test "APCO IE Found"
        } else {
            error.an "Unable to find find APCO IE"
        }
		
		if { [regexp.an "(163)\"" $out] } {
            log.test "APCO IE Type Verified"
        } else {
            error.an "Failed to verify APCO IE Type; Expected is 163"
        }
		
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: P-CSCF IPv4 Address Request (0x000c)' | sed -n '1p'"]
		
		if { [regexp.an "(0x000c)" $out] } {
            log.test "P-CSCF IPv4 Request ID Verified"
        } else {
            error.an "Failed to verify P-CSCF IPv4 Request ID ; Expected is 0x000c"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: P-CSCF IPv6 Address Request (0x0001)' | sed -n '1p'"]
		
		if { [regexp.an "(0x0001)" $out] } {
            log.test "P-CSCF IPv6 Request ID Verified"
        } else {
            error.an "Failed to verify P-CSCF IPv6 Request ID ; Expected is 0x0001"
        }
        
    }
    
    runStep "Look for P-CSCF IP addresses and verify the corresponding IDs in Response packet" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		#set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.addr==$ip2 && ipv6.addr==$ip1' | grep -e \"Create Session Response\" | awk  '{print \$1}' | sed -n '1p'"]
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Response\" | awk  '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
        
		set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: P-CSCF IPv4 Address (0x000c)' | sed -n '1p'"]
        
        if { [regexp.an "(0x000c)" $out] } {
            log.test "P-CSCF IPv4 Response ID Verified"
        } else {
            error.an "Failed to verify P-CSCF IPv4 Response ID ; Expected is 0x000c"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Protocol or Container ID: P-CSCF IPv6 Address (0x0001)' | sed -n '1p'"]
		
		if { [regexp.an "(0x0001)" $out] } {
            log.test "P-CSCF IPv6 Response ID Verified"
        } else {
            error.an "Failed to verify P-CSCF IPv6 Response ID ; Expected is 0x0001"
        }
        
    }
    
    runStep "Verify that P-CSCF IP address on UE matches with the one allocated by MCC" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv4: $uev4pcscfIp1 ($uev4pcscfIp1)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev4pcscfIp1\"" $out] } {
            log.test "P-CSCF Primary IPv4 Address Verified"
        } else {
            error.an "Failed to verify P-CSCF Primary IPv4 Address ; Expected is $uev4pcscfIp1"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv4: $uev4pcscfIp2 ($uev4pcscfIp2)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev4pcscfIp2\"" $out] } {
            log.test "P-CSCF Secondary IPv4 Address Verified"
        } else {
            error.an "Failed to verify P-CSCF Secondary IPv4 Address ; Expected is $uev4pcscfIp2"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv6: $uev6pcscfIp1 ($uev6pcscfIp1)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev6pcscfIp1\"" $out] } {
            log.test "P-CSCF Primary IPv6 Address Verified"
        } else {
            error.an "Failed to verify P-CSCF Primary IPv6 Address ; Expected is $uev6pcscfIp1"
        }
        
        set out [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"IPv6: $uev6pcscfIp2 ($uev6pcscfIp2)\"' | sed -n '1p'"]
        
        if { [regexp.an "show=\"$uev6pcscfIp2\"" $out] } {
            log.test "P-CSCF Secondary IPv6 Address Verified"
        } else {
            error.an "Failed to verify P-CSCF Secondary IPv6 Address ; Expected is $uev6pcscfIp2"
        }
        
        
	}
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80133
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/05/2016
set pctComp   100
set summary   "This test verifies Session with no IDr (APN) from UE, ePDG is mapped to a default APN"
set descr     "
1.  Check if APN is configured on MCC for default gateway profile
2.  Disable the APN that is configured on UE
3.  Verify that UE gets APN as configured on MCC for default profile"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Check if APN is configured on MCC for default gateway profile" {        
        
        set out [dut exec "show running-config zone default gateway epdg apn-list"]
        
        if { [regexp.an {apn-list ([-0-9.a-z]+)} $out - apn1] } {
            log.test "Default APN found: $apn1"
        } else {
            error.an "Default APN is not configured"
        }
        
    }
    
    runStep "Disable the APN that is configured on UE" {
        
        ue exec "sed -i 's/#*rightid=apn.epdg-access-pi.net/#rightid=apn.epdg-access-pi.net/g' /etc/ipsec.conf"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
        
        set apn2 [cmd_out . values.[cmd_out . key-values].APN]
        
        if { $apn1 == $apn2 } {
            log.test "Default APN and Mapped APN are matched"
        } else {
            error.an "Default APN ($apn1) and Mapped APN ($apn2) do not match; Both should be same"
        }
        
    }
    
    runStep "Verify that UE gets APN as configured on MCC for default profile" {
                
        set out [dut exec "show running-config zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 mapped-apn-name"]
        
        if { [regexp.an {mapped-apn-name ([-0-9.a-z]+)} $out - apn3] } {
            log.test "Mapped APN found on MCC: $apn3"
        } else {
            error.an "Unable to find Mapped APN"
        }
        
        if { $apn3 == $apn2 } {
            log.test "Default APN and Mapped APN are matched"
        } else {
            error.an "Default APN ($apn2) and Mapped APN ($apn3) do not match; Both should be same"
        }
        
    }
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
    
}

# ==============================================================
set id        ePDG:section1:EPDG:C80162
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/06/2016
set pctComp   100
set summary   "This test verifies that rekey works as expected on ePDG for IPSec SA - remote end rekey"
set descr     "
1.  Change the IPSec lifetime on UE
2.  Start the session and verify that rekey value gets incremented by 1 after 'lifetime' period"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the IPSec lifetime on UE" {

        ue exec "sed -i 's/#*lifetime=5h/lifetime=50s/g' /etc/ipsec.conf"
        ue exec "sed -i 's/#*margintime=20s/margintime=5s/g' /etc/ipsec.conf"
        
        set out [dut exec "show security statistics network-context SWU"]
        set var1 [cmd_out . values.SWU.REKEYEDTRANSFORMS]
        
    }
    
    runStep "Start the session and verify that rekey value gets incremented by 1 after 'lifetime' period" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        sleep 45  
        
        set out [dut exec "show security statistics network-context SWU"]
        set var2 [cmd_out . values.SWU.REKEYEDTRANSFORMS]

        if { $var2 == [expr $var1 +1] } {
            log.test "Rekey works as expected"
        } else {
            error.an "Rekey scheduling failed; Check 'lifetime' in IPSec configuration on StrongSwan"
        }
                    
    }
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C120237
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/06/2016
set pctComp   100
set summary   "This test verifies that rekey works as expected on ePDG for IKE SA - remote end rekey"
set descr     "
1.  Change the IKE lifetime on UE
2.  Start the session and verify that rekey value gets incremented by 1 after 'lifetime' period"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the IKE lifetime on UE" {

        ue exec "sed -i 's/#*ikelifetime=7h/ikelifetime=50s/g' /etc/ipsec.conf"
        ue exec "sed -i 's/#*margintime=20s/margintime=5s/g' /etc/ipsec.conf"
        
        set out [dut exec "show security statistics network-context SWU"]
        set var1 [cmd_out . values.SWU.TOTALIKEREKEYEDTUNNELS]
        
    }
    
    runStep "Start the session and verify that rekey value gets incremented by 1 after 'lifetime' period" {
                
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        sleep 45  
        
        set out [dut exec "show security statistics network-context SWU"]
        set var2 [cmd_out . values.SWU.TOTALIKEREKEYEDTUNNELS]
        
        if { $var2 == [expr $var1 +1] } {
            log.test "Rekey works as expected"
        } else {
            error.an "Rekey scheduling failed; Check 'ikelifetime' in IPSec configuration on StrongSwan"
        }
                    
    }
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C287645
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/22/2016
set pctComp   100
set summary   "This test verifies the P-CSCF IPv4 address attributes (Telus IoT Standard)"
set descr     "
1.  Start the session and decrypt the IPSec packets
2.  Find P-CSCF IP v4 private address attribute configured on MCC
3.  Filter out the IPSec packets from capture and verify if P-CSCF IPv4 Private address Attribute is same as that of configured on MCC
4.  Enable the public Attribute type and decrypt the IPSec packets for a new seesion
5.  Filter out the IPSec packets from capture and verify if P-CSCF IPv4 Public address Attribute is same as that of configured on MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and decrypt the IPSec packets" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"

        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"
        sleep 1
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
        
    }
    
    runStep "Find P-CSCF IP v4 private address attribute configured on MCC" {
        
        set out [dut exec "show running-config zone default gateway epdg p-cscf-v4-private-attribute-type"]
        
        if { [regexp.an {p-cscf-v4-private-attribute-type ([0-9]+)} $out - attrv4] } {
            log.test "P-CSCF IPv4 address attribute found on MCC: $attrv4"
        } else {
            error.an "P-CSCF IPv4 address attribute is not configured on MCC"
        }
        
        if { $attrv4 == 16384 } {
            log.test "Found P-CSCF IP v4 address attributes"
        } else {
            error.an "Unable to find P-CSCF address attributes; Expected is 16384 for v4"
        }
        
    }
    
    runStep "Filter out the IPSec packets from capture and verify if P-CSCF IPv4 Private address Attribute is same as that of configured on MCC" {
    
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e IKE_AUTH | sed '$!d' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y frame.number==$out2 -T pdml | grep -o '<field name=\"isakmp.cfg.attr\" showname=\"Attribute Type: (t=16384,l=4) PRIVATE USE\"' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
        
        if { [regexp "2" $out2] } {
            log.test "Two P-CSCF IPv4 Private address Attributes found"
        } else {
            error.an "P-CSCF IPv4 Private address attribute mismatch; check the strongswan configuration on UE"
        }
        
    }
    
    runStep "Enable the public Attribute type and decrypt the IPSec packets for a new seesion" {
             
        ue exec "sed -i 's/#*enable-old /enable /g' /etc/strongswan.d/charon/p-cscf.conf"
        ue exec "cat /etc/strongswan.d/charon/p-cscf.conf"
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"
        sleep 1
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
        
    }
    
    runStep "Filter out the IPSec packets from capture and verify if P-CSCF IPv4 Public address Attribute is same as that of configured on MCC" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e IKE_AUTH | sed '$!d' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y frame.number==$out2 -T pdml | grep -o '<field name=\"isakmp.cfg.attr\" showname=\"Attribute Type: (t=20,l=4) P_CSCF_IP4_ADDRESS\"' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
       
        if { [regexp "2" $out2] } {
            log.test "Two P-CSCF IPv4 Standard (IANA) address attributes found"
        } else {
            error.an "P-CSCF IPv4 Standard (IANA) address attribute mismatch; check the strongswan configuration on UE"
        }
       
    }
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    catch {ue exec "cp /etc/strongswan.d/charon/p-cscf.conf.antaf /etc/strongswan.d/charon/p-cscf.conf"}
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C321464
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/22/2016
set pctComp   100
set summary   "This test verifies the P-CSCF IPv6 address attributes (Telus IoT Standard)"
set descr     "
1.  Start the session and decrypt the IPSec packets
2.  Find P-CSCF IP v6 private address attribute configured on MCC
3.  Filter out the IPSec packets from capture and verify if P-CSCF IPv6 Private address Attribute is same as that of configured on MCC
4.  Enable the public Attribute type and decrypt the IPSec packets for a new seesion
5.  Filter out the IPSec packets from capture and verify if P-CSCF IPv6 Public address Attribute is same as that of configured on MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start the session and decrypt the IPSec packets" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"

        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"
        sleep 1
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
        
    }
    
    runStep "Find P-CSCF IP v6 private address attribute configured on MCC" {
        
        set out [dut exec "show running-config zone default gateway epdg p-cscf-v6-private-attribute-type"]
        
        if { [regexp.an {p-cscf-v6-private-attribute-type ([0-9]+)} $out - attrv6] } {
            log.test "P-CSCF IPv6 address attribute found on MCC: $attrv6"
        } else {
            error.an "P-CSCF IPv6 address attribute is not configured on MCC"
        }
        
        if { $attrv6 == 16390 } {
            log.test "Found P-CSCF IPv6 address attributes"
        } else {
            error.an "Unable to find P-CSCF address attributes; Expected is 16390 for v6"
        }
        
    }
    
    runStep "Filter out the IPSec packets from capture and verify if P-CSCF IPv6 Private address Attribute is same as that of configured on MCC" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e IKE_AUTH | sed '$!d' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y frame.number==$out2 -T pdml | grep -o '<field name=\"isakmp.cfg.attr\" showname=\"Attribute Type: (t=16390,l=17) PRIVATE USE\"' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
        
        if { [regexp "2" $out2] } {
            log.test "Two P-CSCF IPv6 Private address Attributes found"
        } else {
            error.an "P-CSCF IPv6 Private address attribute mismatch; check the strongswan configuration on UE"
        }
        
    }
    
    runStep "Enable the public Attribute type and decrypt the IPSec packets for a new seesion" {
        
        ue exec "sed -i 's/#*enable-old /enable /g' /etc/strongswan.d/charon/p-cscf.conf"
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
            
        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"
        sleep 1
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
        
    }
    
    runStep "Filter out the IPSec packets from capture and verify if P-CSCF IPv6 Public address Attribute is same as that of configured on MCC" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e IKE_AUTH | sed '$!d' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y frame.number==$out2 -T pdml | grep -o '<field name=\"isakmp.cfg.attr\" showname=\"Attribute Type: (t=21,l=16) P_CSCF_IP6_ADDRESS\"' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - out2
       
        if { [regexp "2" $out2] } {
            log.test "Two P-CSCF IPv6 Standard (IANA) address attributes found"
        } else {
            error.an "P-CSCF IPv6 Standard (IANA) address attribute mismatch; check the strongswan configuration on UE"
        }
       
    }
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    catch {ue exec "cp /etc/strongswan.d/charon/p-cscf.conf.antaf /etc/strongswan.d/charon/p-cscf.conf"}
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C120324
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/11/2016
set pctComp   100
set summary   "This test verifies that rekey works as expected if ePDG initiates rekey for IPSec SA"
set descr     "
1.  Find the IPSec lifetime configured on MCC
2.  Start the session and check if session is up after rekeying occured
3.  Check the Data Path and verify that rekey value gets incremented by 1 or 2 after 'lifetime' period"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Find the IPSec lifetime configured on MCC" {

        ue exec "ipsec restart"
        
        set out [dut exec "show running-config security policy tunnel SWU"]
        regexp.an -lineanchor {^\s*ipsec-life-time\s+([0-9]+)$} $out - ips_lyftym
        
        if { $ips_lyftym <= 600 } {
            set margintime 30
        }   elseif { 600 < $ips_lyftym && $ips_lyftym <= 6000 } {
                set margintime [expr $ips_lyftym/20]
        } else {
            set margintime 300
        }
        
        set sleeptime [expr $ips_lyftym + $margintime]
        #AN-26093
        
        set out [dut exec "show security statistics network-context SWU"]
        set var1 [cmd_out . values.SWU.REKEYEDTRANSFORMS]
        
    }
    
    runStep "Start the session and check if session is up after rekeying occured" {
                
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        sleep $sleeptime
        
        set out [dut exec "show security statistics network-context SWU"]
        set var2 [cmd_out . values.SWU.REKEYEDTRANSFORMS]
        
        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
    }
    
    runStep "Check the Data Path and verify that rekey value gets incremented by 1 or 2 after 'lifetime' period" {
        
        catch {ue exec "ping -I $ipsec(ueIp4) [tb _ os.ip] -c 5 -i 0.2"} result		
        
        if { $var2 == [expr $var1 +1] || $var2 == [expr $var1 +2] } {
            if { [regexp.an " 0% packet loss" $result] } {
                log.test "IPSec Rekey works as expected"
            } else {
                error.an "Packet loss during ICMP Ping; Retry"
            }
        } else {
            error.an "IPSec Rekey scheduling failed; Check DUT configuration"
        }
           
    }
    
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C120323
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/12/2016
set pctComp   100
set summary   "This test verifies that rekey works as expected if ePDG initiates rekey for IKE SA"
set descr     "
1.  Find the IKE lifetime configured on MCC
2.  Start the session and check if session is up after rekeying occured
3.  Check the Data Path and verify that rekey value gets incremented by 1 or 2 after 'lifetime' period"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Find the IKE lifetime configured on MCC" {

        ue exec "ipsec restart"
                
        set out [dut exec "show running-config security policy tunnel SWU"]
        regexp.an -lineanchor {^\s*ike-life-time\s+([0-9]+)$} $out - ike_lyftym
                
        if { $ike_lyftym <= 10000 } {
            set margintime 100
        }   elseif { 10000 < $ike_lyftym && $ike_lyftym <= 60000 } {
                set margintime [expr $ike_lyftym/100]
        } else {
            set margintime 600
        }
        
        set sleeptime [expr $ike_lyftym + $margintime]
        #AN-26093
                       
        set out [dut exec "show security statistics network-context SWU"]
        set var1 [cmd_out . values.SWU.TOTALIKEREKEYEDTUNNELS]
        
    }
    
    runStep "Start the session and check if session is up after rekeying occured" {
                
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        sleep $sleeptime  
        
        set out [dut exec "show security statistics network-context SWU"]
        set var2 [cmd_out . values.SWU.TOTALIKEREKEYEDTUNNELS]
        
        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
    }
        
    runStep "Check the Data Path and verify that rekey value gets incremented by 1 or 2 after 'lifetime' period" {
        
        catch {ue exec "ping -I $ipsec(ueIp4) [tb _ os.ip] -c 5 -i 0.2"} result		
        
        if { $var2 == [expr $var1 +1] || $var2 == [expr $var1 +2] } {
            if { [regexp.an " 0% packet loss" $result] } {
                log.test "IKE Rekey works as expected"
            } else {
                error.an "Packet loss during ICMP Ping; Retry"
            }
        } else {
            error.an "IKE Rekey scheduling failed; Check DUT configuration"
        }        
        
    }
    
} {
    # Cleanup
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80337
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   07/12/2016
set pctComp   100
set summary   "This test verifies that UE gets connected to 2 APNs simultaneously with same IMSI (REQ 4106)"
set descr     "
1.  Start IPSec session and find the session ID on MCC
2.  Find IMSI and APN corresponding to that session
3.  Start a new IPSec session with different APN
4.  Verify if IPSec tunnel is present between UE and ePDG and UE gets IP v4 and v6 addresses
5.  Check the data path between UE and OS
6.  Check if both IPSec sessions are present on MCC
7.  Check if UE is able to connect to different APNs with same IMSI"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Start IPSec session and find the session ID on MCC" {

        dut exec config "no workflow control-profile CONTROL-PROFILE-PGW default-pcrf-interface PCRF_CHRG"
        dut exec config "commit"
        
        ue exec "ipsec restart"
            
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
                        
        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id1 [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id1"
        }
        
    }
    
    runStep "Find IMSI and APN corresponding to that session" {

        set imsi1 [cmd_out . values.$id1.IMSI]
        puts "Found IMSI: $imsi1"
        set apn1 [cmd_out . values.$id1.APN]
        puts "Found 1st APN: $apn1"
        
    }
    
    runStep "Start a new IPSec session with different APN" {
              
        set out1 [ue exec "ipsec up epdg-apn2" -exitCode 0]
        
    }
    
    runStep "Verify if IPSec tunnel is present between UE and ePDG and UE gets IP v4 and v6 addresses" {

        if { [regexp.an "connection 'epdg-apn2' established successfully" $out1] } {
            log.test "UE reports: connection 'epdg-apn2' established successfully"
        } else {
            error.an "Failed to establish 'epdg-apn2' connection"
        }

        if { [regexp.an {installing new virtual IP ([0-9.]+)\sinstalling new virtual IP ([0-9:a-z]+)} $out1 - ueIpv4 ueIpv6] } {
            log.test "Found new virtual IPv4 and IPv6: $ueIpv4 $ueIpv6"
        } else {
            error.an "Failed to retrieve new virtual IPs"
        }

        dut exec "show subscriber summary gateway-type epdg"
       
        if { ![string is integer -strict [set id_ [lindex [cmd_out . key-values] 1]]] } {
            error.an "Expected Two epdg session"
        } else {
            log.test "Found 2nd epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*ue-v4-ip-address\s+([0-9.]+)$} $out - ueIp4] } {
            log.test "Found ue-v4-ip-address: $ueIp4"
        } else {
            error.an "Failed to retrieve ue-v4-ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*ue-v6-ip-address\s+([0-9:a-z]+)$} $out - ueIp6] } {
            log.test "Found ue-v6-ip-address: $ueIp6"
        } else {
            error.an "Failed to retrieve ue-v6-ip-address"
        }

        if { $ueIpv4 == $ueIp4 && $ueIpv6 == $ueIp6 } {
            log.test "UE IP addresses as reported by UE and MCC match"
        } else {
            error "UE IP addresses as reported by UE ($ueIpv4 & $ueIpv6) and MCC ($ueIp4 & $ueIp6) do not match"
        }

        set out [ue exec "ip -o addr show up primary scope global"]

        if { [regexp "$ueIp4" $out] && [regexp "$ueIp6" $out]  } {
            log.test "IP address reported by UE"
        } else {
            error.an "UE does not report the new IP ($ueIp4 and $ueIp6) as active"
        }
        
    }
    
    runStep "Check the data path between UE and OS" {
        
        catch {ue exec "ping -I $ueIp4 [tb _ os.ip] -c 5 -i 0.2"} result
		
        if { [regexp.an " 0% packet loss" $result] } {
        log.test "Data Tarnsferred Successfully, without any loss"
        } else {
            error.an "Packet loss during ICMP Ping; Retry"
        }
        
    }
        
    runStep "Check if both IPSec sessions are present on MCC" {
        
        dut exec "show subscriber summary gateway-type epdg"
       
        if { ![string is integer -strict [set id2 [lindex [cmd_out . key-values] 1]]] } {
            error.an "Expected Two epdg session"
        } else {
            log.test "Found 2nd epdg session with id: $id2"
        }
        
    }
    
    runStep "Check if UE is able to connect to different APNs with same IMSI" {
        
        set imsi2 [cmd_out . values.$id2.IMSI]
        puts "Found IMSI: $imsi2"
        set apn2 [cmd_out . values.$id2.APN]
        puts "Found 2nd APN: $apn2"

        if {$imsi1 == $imsi2 } {
            if {[string match $apn1 $apn2] == 0} {
                log.test "Found Two epdg sessions with different APNs ($apn1 and $apn2) with same IMSI ($imsi1)"
            } else {
                error.an "Two epdg sessions are expected with different APNs but with same IMSI"
            }
        } else { 
            error.an "Both IMSIs should get matched"
        }
    
    }
} {
    # Cleanup
    dut exec config "workflow control-profile CONTROL-PROFILE-PGW default-pcrf-interface PCRF_CHRG"
    dut exec config "commit"
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80338
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   1/4/2017
set pctComp   100
set summary   "REQ 4106 - same IMSI - 2 APNs with 2 dedicated bearers"
set descr     "
1.  Start 2nd PCRF Server and Verify PCRF-2 server is listening
2.  Start 2nd PCRF Server and Verify PCRF-2 server is listening
3.  Bring v4 Sessions with 2 APNs and pass the Data
4.  Verify the Bearer Stats on MCC
5.  Bring v6 Sessions with 2 APNs and pass the Data
6.  Verify the Bearer Stats on MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Change Workflow Subscriber Analyzer Config" {

        dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG; no key key1"
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1"
        dut exec config "commit"        
        dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG key key1 epdg-name EPDG-1"        
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 apn-name apn.epdg-access-pi.net"
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW-2 priority 7 action data-profile DATA-PROFILE-2 control-profile CONTROL-PROFILE-PGW-2"
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW-2 key key1 apn-name apn2.epdg-access-pi.net"
        dut exec config "commit"
        
    }
    
    runStep "Start 2nd PCRF Server and Verify PCRF-2 server is listening" {
        
        pcrfsim2 init
        sleep 5
       
        set out [dut exec "show service-construct interface aaa-interface-group diameter peer-status"]

        if { [set status_ [cmd_out . values.PCRF-2.STATUS]] == "okay" } {
            log.test "PCRF-2 Server is connected to PGW; PCRF-2 STATUS is 'okay'"
        } else {
            error.an "PCRF-2 Server is not connected to PGW; Expected PCRF-2 STATUS to be 'okay' but got '$status_'"
        }
            
    }

    runStep "Bring v4 Sessions with 2 APNs and pass the Data" {

        array set ipsec2 [ePDG:start_ipsec_sessionv4_2apns]
        ePDG:ue_ping_os $ipsec2(ueIp4_1)
        ePDG:ue_ping_os2 $ipsec2(ueIp4_1)
        ePDG:ue_tcp_os $ipsec2(ueIp4_1)
        ePDG:ue_ping_os $ipsec2(ueIp4_2)
        ePDG:ue_ping_os2 $ipsec2(ueIp4_2)
        ePDG:ue_tcp_os $ipsec2(ueIp4_2)
    
    }
    
    runStep "Verify the Bearer Stats on MCC" {
        
        for {set i 0} {$i < 2} {incr i} {
        
            set index $i
            set c1 5
            set c2 5
            set c3 14
            set c4 12
            set c5 5
            set c6 5
            ePDG:verifyBearerStats index $index c1 $c1 c2 $c2 c3 $c3 c4 $c4 c5 $c5 c6 $c6
            
        }
        
    }
    
    runStep "Bring v6 Sessions with 2 APNs and pass the Data" {
        
        array set ipsec2 [ePDG:start_ipsec_sessionv6_2apns]
        ePDG:ue_ping6_os $ipsec2(ueIp6_1)
        ePDG:ue_ping6_os2 $ipsec2(ueIp6_1)
        ePDG:ue_tcp6_os $ipsec2(ueIp6_1)
        ePDG:ue_ping6_os $ipsec2(ueIp6_2)
        ePDG:ue_ping6_os2 $ipsec2(ueIp6_2)
        ePDG:ue_tcp6_os $ipsec2(ueIp6_2)
    
    }
    
    runStep "Verify the Bearer Stats on MCC" {
        
        for {set i 0} {$i < 2} {incr i} {
        
            set index $i
            set c1 5
            set c2 5
            set c3 14
            set c4 12
            set c5 5
            set c6 5
            ePDG:verifyBearerStats index $index c1 $c1 c2 $c2 c3 $c3 c4 $c4 c5 $c5 c6 $c6
            
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "no workflow subscriber-analyzer SUB-ANA-PGW-2"
    dut exec config "commit"        
    dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG; no key key1"
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1"
    dut exec config "commit"        
    dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG key key1 apn-name apn.epdg-access-pi.net"        
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1"        
    dut exec config "commit"    
    pcrfsim2 stop
    sleep 5
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80161
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   7/14/2016
set pctComp   100
set summary   "This test verify the Session with DPD enabled - ePDG clears subscriber after DPD timeout with no data"
set descr     "
1.  Find the DPD timeout period configured on MCC
2.  Capture the packets on SWU interface and start the session
3.  Check if onle one session/tunnel is active/present
4.  Reboot the UE to terminate/disable the routes from ePDG to UE and verify that for 'DPD' time, ePDG keeps trying to connect to UE
5.  Check if no any session/tunnel is active/present
6.  Verify from the packet capture that after 'DPD' time MCC deletes the session
7.  Verify from the packet capture that after UE is not active and response payload is empty"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Find the DPD timeout period configured on MCC" {
	
		set out [dut exec "show running-config security policy tunnel SWU epdg-tunnel dead-peer-detection"]
        regexp.an -lineanchor {^\s*dead-peer-detection\s+([0-9]+)$} $out - dpdtime
    
        ue exec "ipsec restart"
        
    }
    
    runStep "Capture the packets on SWU interface and start the session" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
    }
        
    runStep "Check if onle one session/tunnel is active/present" {
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 1 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 1} {
            log.test "Only 1 IKE & IPSec tunnel is Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 1"
        }
        
    }
    
    runStep "Reboot the UE to terminate/disable the routes from ePDG to UE and verify that for 'DPD' time, ePDG keeps trying to connect to UE" {
        
        catch {ue exec "reboot"}
        set sleeptime [expr $dpdtime + 20]
        sleep $sleeptime
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Check if no any session/tunnel is active/present" {
        
        set out [dut exec "show subscriber summary gateway-type epdg"]
        
        if { [regexp.an "No entries found." $out] } {
            log.test "No any epdg session found"
        } else {
            error.an "Found epdg session"
        }
        
        dut exec "show security statistics network-context"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 0 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 0} {
            log.test "No any IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 0"
        }
		
    }
    
    runStep "Verify from the packet capture that after 'DPD' time MCC deletes the session" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'isakmp'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp' |  grep -e INFORMATIONAL | awk '{print \$1}' | sed -n '1p'"]
        set out2 [ePDG:store_last_line $out1]
		set out1 [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Next payload: Delete (42)' | sed -n '1p'"]
		set out2 [ePDG:store_last_line $out1]
                
    	if { [regexp.an "<field name=\"isakmp.nextpayload\"" $out2] && [regexp.an "value=\"2a\"" $out2] } {
            log.test "Found Session Delete request"
        } else {
            error.an "No Session Delete request found"
        }
						
    }
    
    runStep "Verify from the packet capture that after UE is not active and response payload is empty" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp' |  grep -e INFORMATIONAL | awk '{print \$1}' | sed -n '2p'"]
        set out2 [ePDG:store_last_line $out1]
		set out1 [tshark exec "tshark -r /tmp/umakant -Y frame.number==$out2 -T pdml | grep -e 'showname=\"Next payload: NONE / No Next Payload' | sed -n '1p'"]
		set out2 [ePDG:store_last_line $out1]
        
        if { [regexp.an "<field name=\"isakmp.nextpayload\"" $out2] && [regexp.an "value=\"00\"" $out2] } {
            log.test "Found Response with empty payload; Peer is dead"
        } else {
            error.an "Peer is still alive; Check DPD timeout period"
        }
	}
} {
    # Cleanup
    ePDG:clear_tshark_data
    ue closeCli
    ue initCli -4 true
    ue_init
    ue exec "ipsec restart"
    dut exec "subscriber clear-local"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C339692
set category  "AES-GCM support for ESP (REQS-4466)"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   7/28/2016
set pctComp   100
set summary   "This test verifies that aes192gcm16 transform can be negotiated and session comes up fine and ping data works"
set descr     "
1. Change the Certificate type from AES-256 to AES192GCM16 in ipsec.conf file on UE
2. Start the session and check data path by pinging OS
3. Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from AES-256 to AES-192GCM-16 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192gcm16-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        ue exec "modprobe -rf aesni-intel"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_GCM_16_192/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_GCM_16_192," $out] ==1} {
            log.test "aes192gcm16 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes192gcm16 ESP Transform"
        }
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-gcm/192 - None"] == 1 } {
            log.test "aes192gcm16 ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes192gcm16 ESP Transform on MCC"
        }
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    catch {ue exec "reboot"}
    sleep 30
    ue closeCli
    ue initCli -4 true
    ue_init
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
    
}

# ==============================================================
set id        ePDG:section1:EPDG:C339693
set category  "AES-GCM support for ESP (REQS-4466)"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   7/28/2016
set pctComp   100
set summary   "This test verifies that verify aes256gcm8 transform can be negotiated and session comes up fine and ping data works"
set descr     "
1. Change the Certificate type from AES-256 to AES256GCM8 in ipsec.conf file on UE
2. Start the session and check data path by pinging OS
3. Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from AES-256 to AES-256GCM-8 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256gcm8-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        ue exec "modprobe -rf aesni-intel"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_GCM_8_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_GCM_8_256," $out] ==1} {
            log.test "aes256gcm8 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes256gcm8 ESP Transform"
        }
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-gcm-64/256 - None"] == 1 } {
            log.test "aes256gcm8 ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes256gcm8 ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    catch {ue exec "reboot"}
    sleep 30
    ue closeCli
    ue initCli -4 true
    ue_init
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup    
}

# ==============================================================
set id        ePDG:section1:EPDG:C80178
set category  "IPv6 Transport and UE with IPv6 data"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/1/2016
set pctComp   100
set summary   "Test verifies session with ePDG and UE's control n/w using IPv6 but GTP-c on IPv6 - AES256-SHA2-256-DH14 - UE data on IPv6"
set descr     "
1.  Get ePDG and PGW addresses configured on MCC
2.  Change the left and right fileds in ipsec.conf on UE to IPv6 addresses
3.  Get the Weights for PGW IPv4 and IPv6 addresses configured on MCC
4.  Check if weight for IPv6 is more than IPv4; if not alter those values
5.  Capture the Packets and start the session
6.  Import SWU-interface Tshark file
7.  Verify if control path from UE is IPv6 i.e, All ISAKMP packets have IPv6 address
8.  Verify if data path from UE is IPv6 i.e, All ESP packets have IPv6 address
9.  Import S2B-interface Tshark file
10. Get the Source and Destination IP addresses of the GTP-C messages
11. Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
12. Find out the Ping Packets from UE to OS to verify IPv6 data path on S2B interface
13. Import GI-interface Tshark file
14. Find out the Ping Packets from UE to OS to verify IPv6 data path on GI interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Get ePDG and PGW IPv4 and IPv6 addresses (on SWU interface) from MCC" {
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - epdg_swu_lbv4
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V6 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9:a-z]+)} $ip_info - epdg_swu_lbv6
        
        set ip_info [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_lb_v4
        
        set ip_info [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9:a-z]+)} $ip_info - pgw_lb_v6
       
    }
        
    runStep "Change the left and right fileds in ipsec.conf on UE to IPv6 addresses" {
        
        #catch {ue exec "ip addr flush eth1"}
        #catch {ue exec "systemctl restart networking.service"}
        #ue closeCli
        #ue initCli -4 true
        #ue exec "ipsec restart"
        
        ue exec "sed -i 's/#*left=[tb _ ue.ip]/left=[tb _ ue.ipv6]/g' /etc/ipsec.conf"
        
        ue exec "sed -i 's/#*right=$epdg_swu_lbv4/right=$epdg_swu_lbv6/g' /etc/ipsec.conf"
        
    }
        
    runStep "Get the Weights for PGW IPv4 and IPv6 addresses configured on MCC" {

        set pgw_ipv4_info [dut exec "show running-config service-construct pdngw-list PDNGW-LIST-1 ip-address $pgw_lb_v4 weight"]
        
        regexp.an {\s*weight\s([0-9]+)} $pgw_ipv4_info - weight_v4
        
        set pgw_ipv6_info [dut exec "show running-config service-construct pdngw-list PDNGW-LIST-1 ip-address $pgw_lb_v6 weight"]
        
        regexp.an {\s*weight\s([0-9]+)} $pgw_ipv6_info - weight_v6
        
    }
    
    runStep "Check if weight for IPv6 is more than IPv4; if not alter those values" {

        if { $weight_v6 > $weight_v4 } {
            log.test "Default IP connection type is IPv6"
        } else {
            puts "Weight for IPv4 '$weight_v4' is more than that of IPv6 '$weight_v6'; Change the configuration and try again"
        }
    }
    
    runStep "Capture the Packets and start the session" {
        
        ePDG:clear_tshark_data
        ePDG:clear_ipsec_decrypt_data
        catch {dut exec shell "rm /var/log/eventlog/GI-QA-5-1*"}
        catch {dut exec shell "rm /var/log/eventlog/SWU-5-1*"}
        catch {dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*"}

        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name SWU-5-1"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 1000 duration 600 file-name S2B-EPDG-5-1"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 1000 duration 600 file-name GI-QA-5-1"
                
        array set ipsec [ePDG:start_ipsecv6_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate" {
        
        set out [ue exec "ipsec statusall"]

        if { [regexp.an "AES_CBC_256/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES256/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
# ==========================================================================================================================================================================================    
    runStep "Import SWU-interface Tshark file" {
            
        catch { dut exec shell "scp /var/log/eventlog/SWU-5-1* /var/log/pcapFiles/" }        
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/SWU-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/SWU-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/SWU-5-1*" }
        
    }
    
    runStep "Verify if control path from UE is IPv6 i.e, All ISAKMP packets have IPv6 address" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'isakmp'"
       
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp and ipv6.addr==[tb _ ue.ipv6] and ipv6.addr==$epdg_swu_lbv6' | grep 'IKE_SA_INIT' | wc -l"]
		regexp.an -all -lineanchor {\s*([0-9]+)} $out1 - ikesa_packet_count
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp and ipv6.addr==[tb _ ue.ipv6] and ipv6.addr==$epdg_swu_lbv6' | grep 'IKE_AUTH' | wc -l"]
		regexp.an -all -lineanchor {\s*([0-9]+)} $out1 - ikeauth_packet_count
        
        if { $ikesa_packet_count >= 2 && $ikeauth_packet_count >= 2 } {
            log.test "ISAKMP IP Packets are present with mentioned IP addersses;Control n/w from UE is IPv4"
        } else {
            error.an "Mentioned IP addresses in tshark filter are not present in ALL ISAKMP Messages;Control n/w from UE is not IPv4"
        }
       
    }
    
    runStep "Verify if data path from UE is IPv6 i.e, All ESP/ICMPv6 packets have IPv6 address" {
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmpv6 and ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - esp_packet_count
		        
        if { $esp_packet_count == 10 } {
            log.test "ESP IP Packets are present with mentioned IP addersses;Data n/w from UE is IPv6"
        } else {
            error.an "Mentioned IP addresses in tshark filter are not present in ALL ESP Messages;Data n/w from UE is not IPv6"
        }
       
        catch {tshark exec "rm /tmp/umakant"}
        catch {ue exec "rm /usr/share/wireshark/umakant"}
    }
# ==========================================================================================================================================================================================        
    runStep "Import S2B-interface Tshark file" {
        
        catch { dut exec shell "scp /var/log/eventlog/S2B-EPDG-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1*"        
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*" }
        
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_pgw
        
        if { [string match $ip1 $ip_epdg] == 1 && [string match $ip2 $ip_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv6 data path on S2B interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]'"
         
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmpv6 and ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]' | wc -l"]
        set ping_packet_count [ePDG:store_last_line $out1]
        
        if { $ping_packet_count == 10 } {
            log.test "Data path between UE and OS on S2B is IPv6"
        } else {
            error.an "Data path between UE and OS is not IPv6 on S2B Interface"
        }
        
        catch {tshark exec "rm /tmp/umakant"}
    }
# ==========================================================================================================================================================================================    
    runStep "Import GI-interface Tshark file" {
            
        catch { dut exec shell "scp /var/log/eventlog/GI-QA-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/GI-QA-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/GI-QA-5-1*"        
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/GI-QA-5-1*" }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv6 data path on GI interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]'"
         
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'icmpv6 and ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]' | wc -l"]
        set packet_count [ePDG:store_last_line $out1]
        
        if { $packet_count == 10 } {
            log.test "Data path between UE and OS on GI is IPv6"
        } else {
            error.an "Data path between UE and OS is not IPv6 on GI Interface"
        }
        
        catch {tshark exec "rm /tmp/umakant"}
        
    }

} {
    # Cleanup
    #catch {ue exec "ip addr flush eth1"}
    #catch {ue exec "systemctl restart networking.service"}
    #ue closeCli
    #ue initCli -4 true
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    catch {dut exec shell "rm /var/log/eventlog/GI-QA-5-1*"}
    catch {dut exec shell "rm /var/log/eventlog/SWU-5-1*"}
    catch {dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*"}
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
    
}

# ==============================================================
set id        ePDG:section1:EPDG:C80179
set category  "IPv6 Transport and UE with IPv6 data"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/1/2016
set pctComp   100
set summary   "Test verifies session with ePDG and UE's control n/w using IPv4 but GTP-c on IPv6 - AES256-SHA2-256-DH14 - UE data on IPv6"
set descr     "
1.  Get ePDG and PGW addresses configured on MCC
2.  Get the Weights for PGW IPv4 and IPv6 addresses configured on MCC
3.  Check if weight for IPv6 is more than IPv4; if not alter those values
4.  Capture the Packets and start the session
5.  Import SWU-interface Tshark file
6.  Verify if control path from UE is IPv4 i.e, All ISAKMP packets have IPv4 address
7.  Verify if data path from UE is IPv6 i.e, All ESP packets have IPv6 address
8.  Import S2B-interface Tshark file
9. Get the Source and Destination IP addresses of the GTP-C messages
10. Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
11. Find out the Ping Packets from UE to OS to verify IPv6 data path on S2B interface
12. Import GI-interface Tshark file
13. Find out the Ping Packets from UE to OS to verify IPv6 data path on GI interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Get ePDG and PGW IPv4 and IPv6 addresses (on SWU interface) from MCC" {
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - epdg_swu_lbv4
        
        set ip_info [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_lb_v4
        
        set ip_info [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9:a-z]+)} $ip_info - pgw_lb_v6
       
    }
        
    runStep "Get the Weights for PGW IPv4 and IPv6 addresses configured on MCC" {

        set pgw_ipv4_info [dut exec "show running-config service-construct pdngw-list PDNGW-LIST-1 ip-address $pgw_lb_v4 weight"]
        
        regexp.an {\s*weight\s([0-9]+)} $pgw_ipv4_info - weight_v4
        
        set pgw_ipv6_info [dut exec "show running-config service-construct pdngw-list PDNGW-LIST-1 ip-address $pgw_lb_v6 weight"]
        
        regexp.an {\s*weight\s([0-9]+)} $pgw_ipv6_info - weight_v6
        
    }
    
    runStep "Check if weight for IPv6 is more than IPv4; if not alter those values" {

        if { $weight_v6 > $weight_v4 } {
            log.test "Default IP connection type is IPv6"
        } else {
            puts "Weight for IPv4 '$weight_v4' is more than that of IPv6 '$weight_v6'; Change the configuration and try again"
        }
    }
    
    runStep "Capture the Packets and start the session" {

        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name SWU-5-1"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 1000 duration 600 file-name S2B-EPDG-5-1"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 1000 duration 600 file-name GI-QA-5-1"
                
        array set ipsec [ePDG:start_ipsecv6_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate" {
        
        set out [ue exec "ipsec statusall"]

        if { [regexp.an "AES_CBC_256/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES256/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
# ==========================================================================================================================================================================================    
    runStep "Import SWU-interface Tshark file" {
            
        catch { dut exec shell "scp /var/log/eventlog/SWU-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/SWU-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/SWU-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/SWU-5-1*" }
        
    }
    
    runStep "Verify if control path from UE is IPv4 i.e, All ISAKMP packets have IPv4 address" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'isakmp'"
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp and ip.addr==[tb _ ue.ip] and ip.addr==$epdg_swu_lbv4' | grep 'IKE_SA_INIT' | wc -l"]
		regexp.an -all -lineanchor {\s*([0-9]+)} $out1 - ikesa_packet_count
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp and ip.addr==[tb _ ue.ip] and ip.addr==$epdg_swu_lbv4' | grep 'IKE_AUTH' | wc -l"]
		regexp.an -all -lineanchor {\s*([0-9]+)} $out1 - ikeauth_packet_count
        
        if { $ikesa_packet_count >= 2 && $ikeauth_packet_count >= 2 } {
            log.test "ISAKMP IP Packets are present with mentioned IP addersses;Control n/w from UE is IPv4"
        } else {
            error.an "Mentioned IP addresses in tshark filter are not present in ALL ISAKMP Messages;Control n/w from UE is not IPv4"
        }
        
    }
    
    runStep "Verify if data path from UE is IPv6 i.e, All ESP/ICMPv6 packets have IPv6 address" {
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmpv6 and ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - esp_packet_count
		        
        if { $esp_packet_count == 10 } {
            log.test "ESP IP Packets are present with mentioned IP addersses;Data n/w from UE is IPv6"
        } else {
            error.an "Mentioned IP addresses in tshark filter are not present in ALL ESP Messages;Data n/w from UE is not IPv6"
        }
       
        catch {tshark exec "rm /tmp/umakant"}
        catch {ue exec "rm /usr/share/wireshark/umakant"}
    }
# ==========================================================================================================================================================================================        
    runStep "Import S2B-interface Tshark file" {
        
        catch { dut exec shell "scp /var/log/eventlog/S2B-EPDG-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*" }
        
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_pgw
        
        if { [string match $ip1 $ip_epdg] == 1 && [string match $ip2 $ip_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv6 data path on S2B interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]'"
         
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmpv6 and ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]' | wc -l"]
        set ping_packet_count [ePDG:store_last_line $out1]
        
        if { $ping_packet_count == 10 } {
            log.test "Data path between UE and OS on S2B is IPv6"
        } else {
            error.an "Data path between UE and OS is not IPv6 on S2B Interface"
        }
        
        catch {tshark exec "rm /tmp/umakant"}
    }
# ==========================================================================================================================================================================================    
    runStep "Import GI-interface Tshark file" {
            
        catch { dut exec shell "scp /var/log/eventlog/GI-QA-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/GI-QA-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/GI-QA-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/GI-QA-5-1*" }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv6 data path on GI interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]'"
         
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'icmpv6 and ipv6.addr==$ipsec(ueIp6) and ipv6.addr==[tb _ os.ipv6]' | wc -l"]
        set packet_count [ePDG:store_last_line $out1]
        
        if { $packet_count == 10 } {
            log.test "Data path between UE and OS on GI is IPv6"
        } else {
            error.an "Data path between UE and OS is not IPv6 on GI Interface"
        }
        
        catch {tshark exec "rm /tmp/umakant"}
        
    }

} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    catch {dut exec shell "rm /var/log/eventlog/GI-QA-5-1*"}
    catch {dut exec shell "rm /var/log/eventlog/SWU-5-1*"}
    catch {dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
    
}

# ==============================================================
set id        ePDG:section1:EPDG:C80186:C80187
set category  "SWU interface compliance"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/23/2016
set pctComp   100
set summary   "This Test verifies the session with 1 dedicated bearer and data through the dedicated bearer"
set descr     "
1.  Bring up the session and find the PGW session ID
2.  Check if both Default and dedicated bearers are present
3.  Check if the Default bearer stats are reset to zero
4.  Check if the Dedicated bearer stats are reset to zero
5.  Pass the ICMP and TCP traffic
6.  Verify the stats for Dedicated Bearer
7.  Verify the stats for Default Bearer"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the session and find the PGW session ID" {
        
        pcrfsim init
        
        array set ipsec [ePDG:start_ipsec_session]
        
        dut exec "show subscriber summary gateway-type pgw"
		
		if { ![string is integer -strict [set n1 [cmd_out . key-values]]] } {
            error.an "Expected one session"
        } else {
            log.test "Found a session with id: $n1"
        }
        
    }
    
    runStep "Check if both Default and dedicated bearers are present" {
        
        set out [dut exec "show subscriber pdn-session $n1 bearers"]

        if { [regexp.an "$n1\\s(\[0-9]+)\\s*$n1\\s(\[0-9]+)\\s*$n1\\s(\[0-9]+)" $out - bearer_id1 bearer_id2 bearer_id3] } {
            log.test "Found Default Bearer with ID $bearer_id1 and Dedicated Bearer with IDs $bearer_id2 and $bearer_id3"
        } else {
            error.an "Unable to find a default/dedicated bearer"
        }
        
    }
    
    runStep "Count the Default bearer Packets" {
       
        dut exec "show subscriber pdn-bearer $n1 $bearer_id1"
        
        set up_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id1 uplink-green-packets"]
        regexp.an {uplink-green-packets ([0-9]+)} $up_gren_pkts_info - up_gren_pkts_default
        
        set down_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id1 downlink-green-packets"]
        regexp.an {downlink-green-packets ([0-9]+)} $down_gren_pkts_info - down_gren_pkts_default
        
    }
    
    runStep "Check if the Dedicated bearer stats are reset to zero" {
        
        set up_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id2 uplink-green-packets"]
        regexp.an {uplink-green-packets ([0-9]+)} $up_gren_pkts_info - up_gren_pkts2
        
        set down_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id2 downlink-green-packets"]
        regexp.an {downlink-green-packets ([0-9]+)} $down_gren_pkts_info - down_gren_pkts2
        
         set up_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id3 uplink-green-packets"]
        regexp.an {uplink-green-packets ([0-9]+)} $up_gren_pkts_info - up_gren_pkts3
        
        set down_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id3 downlink-green-packets"]
        regexp.an {downlink-green-packets ([0-9]+)} $down_gren_pkts_info - down_gren_pkts3
        
        if { $up_gren_pkts2 == 0 && $down_gren_pkts2 == 0 && $up_gren_pkts3 == 0 && $down_gren_pkts3 == 0 } {
            log.test "Dedicated bearer Stats are reset to Zero"
        } else {
            error.an "Dedicated bearer Stats are not cleared; bring up the new session and try again"
        }
        
    }
    
    runStep "Pass the ICMP and TCP traffic" {
    
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
    }
    
    runStep "Verify the stats for Dedicated Bearer" {
        
        set up_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id2 uplink-green-packets"]
        regexp.an {uplink-green-packets ([0-9]+)} $up_gren_pkts_info - up_gren_pkts2
        
        set down_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id2 downlink-green-packets"]
        regexp.an {downlink-green-packets ([0-9]+)} $down_gren_pkts_info - down_gren_pkts2
		
		set up_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id3 uplink-green-packets"]
        regexp.an {uplink-green-packets ([0-9]+)} $up_gren_pkts_info - up_gren_pkts3
        
        set down_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id3 downlink-green-packets"]
        regexp.an {downlink-green-packets ([0-9]+)} $down_gren_pkts_info - down_gren_pkts3
        
        if { $up_gren_pkts2 == 5 && $down_gren_pkts2 == 5 && $up_gren_pkts3 == 14 && $down_gren_pkts3 == 12 } {
            log.test "ICMP & TCP Data successfully Passed through the Dedicated Bearers"
        } else {
            error.an "Unable to pass the data through dedicated bearers"
        }
        
    }
     
    runStep "Verify the stats for Default Bearer" {
        
        set up_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id1 uplink-green-packets"]
        regexp.an {uplink-green-packets ([0-9]+)} $up_gren_pkts_info - up_gren_pkts
        
        set down_gren_pkts_info [dut exec "show subscriber pdn-bearer $n1 $bearer_id1 downlink-green-packets"]
        regexp.an {downlink-green-packets ([0-9]+)} $down_gren_pkts_info - down_gren_pkts
        
        if { $up_gren_pkts >= [expr $up_gren_pkts_default + 5] && $down_gren_pkts >= [expr $down_gren_pkts_default + 5] } {
            log.test "ICMP Data Passed through Default Bearer"
        } else {
            error.an "Unable to pass the data through default bearer"
        }
    
    }

} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C226550
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/04/2016
set pctComp   100
set summary   "This Test verifies that local CDRs are populated as expected - REQ 4459"
set descr     "
1.  Bring up the session
2.  Decode the .CSV file
3.  Verify the Record Type for ePDG
4.  Verify the details in CDR with those on MCC
5.  Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the session" {
        
        if { [dut . configurator testCmd "service-construct data-record-template epdg charging-local interim epdg-interim duration presentFlag conditional"] == 1 } {
            dut exec config "service-construct data-record-template epdg charging-local interim epdg-interim duration presentFlag conditional"
            dut exec config "commit"   
            log.test "Duration field set to Conditional"  
        } else {
            error.an "Duration Field is not supported on This Build" "" SKIP_TEST            
        }
        
        ue exec "ipsec restart"
        catch {dut exec shell "cd /var/log/datarecord/; rm *"}
        
        array set ipsec [ePDG:start_ipsec_session]        
        sleep 150
        
    }
    
    runStep "Decode the .CSV file and Filter out the Intermediate Record Type" {

        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/cdrProc7.2.0B.pl /var/log/datarecord/" -password [dut . filePassword]
        
        set count [dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR* | wc -l"]        
        dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR*"
        dut exec shell "cd /var/log/datarecord/; perl cdrProc7.2.0B.pl [lindex [cmd_out . full] [expr $count - 1]] > decodedCdrInfo.txt"
        dut exec shell "cd; cat /var/log/datarecord/decodedCdrInfo.txt"
        #set filteredResult [dut exec shell "awk '/(Intermediate)/, /Served PDP Address/' decodedCdrInfo.txt | awk '1;/Served PDP Address/{exit}'"]
        set filteredResult [dut exec shell "awk '/(Intermediate)/, /IKE Local Port/' /var/log/datarecord/decodedCdrInfo.txt | awk '1;/IKE Local Port/{exit}'"]
        
    }
    
    runStep "Verify the Record Type for ePDG" {
        
        regexp.an {\s*Accounting Record Type\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)\s*Record Type\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)} $filteredResult - r1 r2 recordLevel r4 r5 recordType
        
        if { [string match $recordLevel "(Intermediate)"] == 1 && [string match $recordType "(ePDG)"] == 1} {
            log.test "ePDG Intermediate Record Found"
        } else {
            error.an "Unable to find ePDG Intermediate Record"
        }      
        
    }
    
    runStep "Verify the details in CDR with those on MCC" {
        
        set out [dut exec "show running-config service-construct interface offline-charging ePDG-INTF epdg interim-update-interval | include interim-update-interval"]
        if { [regexp.an -lineanchor {^\s*epdg interim-update-interval\s+([0-9]+)$} $out - durationMcc] } {
            log.test "Found Duration value confiured on MCC: $durationMcc"
        } else {
            error.an "Unable to find the Duration value on MCC"
        }
        
        regexp.an -all {\s*Served IMSI\s+\[INT:\s+([0-9]+)\]\s+([-0-9]+)} $filteredResult - r1 imsi
        puts "Served IMSI: $imsi"
        regexp.an -all {\s*Served MNNAI\s+\[INT:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 imsi_nai
        puts "Served MNNAI: $imsi_nai"
        regexp.an -all {\s*ePDG FQDN\s+\[INT:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 fqdn
        puts "ePDG FQDN: $fqdn"
        regexp.an -all {\s*APN ID\s+\[INT:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 apn_id
        puts "APN ID: $apn_id"
        regexp.an -all {\s*Duration\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)\s+seconds\s+\(0 days 0 hours 2 mins 0 secs\)} $filteredResult - r1 time
        puts "DURATION: $time"
        
        if { [string match [tb _ ue.IMSI] $imsi] == 1 && [string match [tb _ ue.imsi_nai] $imsi_nai] == 1 && [string match [tb _ dut.fqdn] $fqdn] == 1 && [string match [tb _ dut.apn1] $apn_id] == 1 && [string match $durationMcc $time] == 1} {
            log.test "CDRs are populated as expected"
        } else {
            error.an "Details in CDR do not match with those configured on MCC"
        }
        
    }
    
    runStep "Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs" {
        
        regexp.an -all {\s*IKE Remote IP Address\s+\[INT:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip1
        regexp.an -all {\s*IKE Remote Port\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port1
        regexp.an -all {\s*IKE Local IP Address\s+\[INT:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip2
        regexp.an -all {\s*IKE Local Port\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port2
        puts "Info Extracted from CDR - IKE Remote IP Address: $ip1 ; IKE Remote Port: $port1 ; IKE Local IP Address: $ip2 ; IKE Local Port: $port2"
        
        regexp.an -all {\s*sending packet: from\s+([0-9.]+)\[([0-9]+)\]\s+to\s+([0-9.]+)\[([0-9]+)\]} $ipsec(ipsecinfo) - ike_ip1 ike_port1 ike_ip2 ike_port2
        puts "Info Extracted from UE - IKE Remote IP Address: $ike_ip1 ; IKE Remote Port: $ike_port1 ; IKE Local IP Address: $ike_ip2 ; IKE Local Port: $ike_port2"        
        
        if { [string match $ip1 $ike_ip1] == 1 && [string match $port1 $ike_port1] == 1 && [string match $ip2 $ike_ip2] == 1 && [string match $port2 $ike_port2] == 1} {
            log.test "IKE IP and Port Info matched"
        } else {
            error.an "IKE IP and Port Info do not match"
        }      
        
    }
    
} {
    # Cleanup    
    catch { dut exec shell "rm /var/log/datarecord/decodedCdrInfo*" }
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C281162
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/06/2016
set pctComp   100
set summary   "This Test verifies the ePDG Start CDR generation and the fields in the record - REQ 4460"
set descr     "
1.  Bring up the session
2.  Decode the .CSV file
3.  Verify the Record Type for ePDG
4.  Verify the details in CDR with those on MCC
5.  Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the session" {
        
        ue exec "ipsec restart"
        catch {dut exec shell "cd /var/log/datarecord/; rm *"}
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ue exec "ipsec restart"
        sleep 10
        
    }
    
    runStep "Decode the .CSV file and Filter out the Start Record Type" {

        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/cdrProc7.2.0B.pl /var/log/datarecord/" -password [dut . filePassword]
        
        set count [dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR* | wc -l"]        
        dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR*"
        dut exec shell "cd /var/log/datarecord/; perl cdrProc7.2.0B.pl [lindex [cmd_out . full] [expr $count - 1]] > decodedCdrInfo.txt"
        dut exec shell "cd; cat /var/log/datarecord/decodedCdrInfo.txt"
        set filteredResult [dut exec shell "awk '/(Start)/, /IKE Local Port/' /var/log/datarecord/decodedCdrInfo.txt | awk '1;/IKE Local Port/{exit}'"]
        
    }
    
    runStep "Verify the Record Type for ePDG" {
        
        regexp.an {\s*Accounting Record Type\s+\[STA:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)\s*Record Type\s+\[STA:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)} $filteredResult - r1 r2 recordLevel r4 r5 recordType
        
        if { [string match $recordLevel "(Start)"] == 1 && [string match $recordType "(ePDG)"] == 1} {
            log.test "ePDG Start Record Found"
        } else {
            error.an "Unable to find ePDG Start Record"
        }      
        
    }
    
    runStep "Verify the details in CDR with those on MCC" {
        
        regexp.an -all {\s*Served IMSI\s+\[STA:\s+([0-9]+)\]\s+([-0-9]+)} $filteredResult - r1 imsi
        puts "Served IMSI: $imsi"
        regexp.an -all {\s*Served MNNAI\s+\[STA:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 imsi_nai
        puts "Served MNNAI: $imsi_nai"
        regexp.an -all {\s*ePDG FQDN\s+\[STA:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 fqdn
        puts "ePDG FQDN: $fqdn"
        regexp.an -all {\s*APN ID\s+\[STA:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 apn_id
        puts "APN ID: $apn_id"        
        
        if { [string match [tb _ ue.IMSI] $imsi] == 1 && [string match [tb _ ue.imsi_nai] $imsi_nai] == 1 && [string match [tb _ dut.fqdn] $fqdn] == 1 && [string match [tb _ dut.apn1] $apn_id] == 1} {
            log.test "CDRs are populated as expected"
        } else {
            error.an "Details in CDR do not match with those configured on MCC"
        }        
    
    }
    
    runStep "Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs" {
        
        regexp.an -all {\s*IKE Remote IP Address\s+\[STA:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip1
        regexp.an -all {\s*IKE Remote Port\s+\[STA:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port1
        regexp.an -all {\s*IKE Local IP Address\s+\[STA:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip2
        regexp.an -all {\s*IKE Local Port\s+\[STA:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port2
        puts "Info Extracted from CDR - IKE Remote IP Address: $ip1 ; IKE Remote Port: $port1 ; IKE Local IP Address: $ip2 ; IKE Local Port: $port2"
        
        regexp.an -all {\s*sending packet: from\s+([0-9.]+)\[([0-9]+)\]\s+to\s+([0-9.]+)\[([0-9]+)\]} $ipsec(ipsecinfo) - ike_ip1 ike_port1 ike_ip2 ike_port2
        puts "Info Extracted from UE - IKE Remote IP Address: $ike_ip1 ; IKE Remote Port: $ike_port1 ; IKE Local IP Address: $ike_ip2 ; IKE Local Port: $ike_port2"        
        
        if { [string match $ip1 $ike_ip1] == 1 && [string match $port1 $ike_port1] == 1 && [string match $ip2 $ike_ip2] == 1 && [string match $port2 $ike_port2] == 1} {
            log.test "IKE IP and Port Info matched"
        } else {
            error.an "IKE IP and Port Info do not match"
        }      
        
    }
    
} {
    # Cleanup
    catch { dut exec shell "rm /var/log/datarecord/decodedCdrInfo*" }
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id         ePDG:section1:EPDG:C308181
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/06/2016
set pctComp   100
set summary   "This Test verifies the ePDG Stop CDR generation and the fields in the record - REQ 4460"
set descr     "
1.  Bring up the session
2.  Decode the .CSV file
3.  Verify the Record Type for ePDG
4.  Verify the details in CDR with those on MCC
5.  Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the session" {
        
        ue exec "ipsec restart"
        catch {dut exec shell "cd /var/log/datarecord/; rm *"}
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ue exec "ipsec restart"
        sleep 10
        
    }
    
    runStep "Decode the .CSV file and Filter out the Stop Record Type" {

        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/cdrProc7.2.0B.pl /var/log/datarecord/" -password [dut . filePassword]
        
        set count [dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR* | wc -l"]        
        dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR*"
        dut exec shell "cd /var/log/datarecord/; perl cdrProc7.2.0B.pl [lindex [cmd_out . full] [expr $count - 1]] > decodedCdrInfo.txt"
        dut exec shell "cd; cat /var/log/datarecord/decodedCdrInfo.txt"
        set filteredResult [dut exec shell "awk '/(Stop)/, /IKE Local Port/' /var/log/datarecord/decodedCdrInfo.txt | awk '1;/IKE Local Port/{exit}'"]
        
    }
    
    runStep "Verify the Record Type for ePDG" {
        
        regexp.an {\s*Accounting Record Type\s+\[STO:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)\s*Record Type\s+\[STO:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)} $filteredResult - r1 r2 recordLevel r4 r5 recordType
        
        if { [string match $recordLevel "(Stop)"] == 1 && [string match $recordType "(ePDG)"] == 1} {
            log.test "ePDG Stop Record Found"
        } else {
            error.an "Unable to find ePDG Stop Record"
        }      
        
    }
    
    runStep "Verify the details in CDR with those on MCC" {
        
        regexp.an -all {\s*Served IMSI\s+\[STO:\s+([0-9]+)\]\s+([-0-9]+)} $filteredResult - r1 imsi
        puts "Served IMSI: $imsi"
        regexp.an -all {\s*Served MNNAI\s+\[STO:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 imsi_nai
        puts "Served MNNAI: $imsi_nai"
        regexp.an -all {\s*ePDG FQDN\s+\[STO:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 fqdn
        puts "ePDG FQDN: $fqdn"
        regexp.an -all {\s*APN ID\s+\[STO:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 apn_id
        puts "APN ID: $apn_id"
        
        if { [string match [tb _ ue.IMSI] $imsi] == 1 && [string match [tb _ ue.imsi_nai] $imsi_nai] == 1 && [string match [tb _ dut.fqdn] $fqdn] == 1 && [string match [tb _ dut.apn1] $apn_id] == 1} {
            log.test "CDRs are populated as expected"
        } else {
            error.an "Details in CDR do not match with those configured on MCC"
        }        
    
    }
    
    runStep "Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs" {
        
        regexp.an -all {\s*IKE Remote IP Address\s+\[STO:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip1
        regexp.an -all {\s*IKE Remote Port\s+\[STO:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port1
        regexp.an -all {\s*IKE Local IP Address\s+\[STO:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip2
        regexp.an -all {\s*IKE Local Port\s+\[STO:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port2
        puts "Info Extracted from CDR - IKE Remote IP Address: $ip1 ; IKE Remote Port: $port1 ; IKE Local IP Address: $ip2 ; IKE Local Port: $port2"
        
        regexp.an -all {\s*sending packet: from\s+([0-9.]+)\[([0-9]+)\]\s+to\s+([0-9.]+)\[([0-9]+)\]} $ipsec(ipsecinfo) - ike_ip1 ike_port1 ike_ip2 ike_port2
        puts "Info Extracted from UE - IKE Remote IP Address: $ike_ip1 ; IKE Remote Port: $ike_port1 ; IKE Local IP Address: $ike_ip2 ; IKE Local Port: $ike_port2"        
        
        if { [string match $ip1 $ike_ip1] == 1 && [string match $port1 $ike_port1] == 1 && [string match $ip2 $ike_ip2] == 1 && [string match $port2 $ike_port2] == 1} {
            log.test "IKE IP and Port Info matched"
        } else {
            error.an "IKE IP and Port Info do not match"
        }      
        
    }
    
} {
    # Cleanup
    catch { dut exec shell "rm /var/log/datarecord/decodedCdrInfo*" }
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section2:S6B:C226244
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/26/2016
set pctComp   100
set summary   "This test verifies that PGW initiates the termination with session_id and user name in STR matching a PDN session , verify STA from 3GPP"
set descr     "
1.  Start the Packet Capture on GI interface and bring up the session ; Verify Data Path
2.  Terminate the Session from PGW and Stop Packet capture
3.  Decode TCP Packets as DIAMETER and Import STR Packet info
4.  Find out the session ID and username info from STR
5.  Verify the session ID and username with the PDN Session
6.  Verify the Termination cause in STR
7.  Verify the session ID in STA
8.  Verify the Diameter Result in STA
9.  Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Record the initial Stats ; Start the Packet Capture on GI interface and bring up the session ; Verify Data Path" {
        
        dut exec "subscriber clear"
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"        
        sleep 5
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aar_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
                
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
    }
    
    runStep "Terminate the Session from PGW and Stop Packet capture" {
        
        dut exec "subscriber clear"
        dut exec "subscriber clear-local"
        
        set subscriber_info [dut exec "show subscriber summary"]
        
        if { [regexp.an " No entries found" $subscriber_info] } {
            log.test "Subscriber cleared by PGW"
        } else {
            dut exec "subscriber clear-local"
            sleep 5
        }
  
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import STR Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }
    
    runStep "Find out the session ID and username info from STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.User-Name\" showname=\"User-Name: ' | sed -n '1p'"]
        set username_info [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_str [ePDG:store_last_line $out1]
        
    }
    
    runStep "Verify the session ID and username with the PDN Session" {
        
        regexp.an {\"User-Name:\s([_0-9.a-zA-Z:;-]+)} $username_info - username
        
        if { [string match $username "[tb _ dut.apn1]"] } {
            log.test "Username matched"
        } else {
            error.an "Username does not match"
        }
        
        regexp.an {\"Session-Id:\s([_0-9.a-zA-Z:;-]+)} $sessionid_info_str - sessionid
        
        if { [regexp.an ";$ipsec(pgw_sessionid);" $sessionid] } {
            log.test "PGW Session ID Matched"
        } else {
            error.an "PGW Session ID does not match"
        }
        
    }
    
    runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause "DIAMETER_LOGOUT"] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Expected is DIAMETER_LOGOUT"
        }
        
    }        
    
    runStep "Verify the session ID in STA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Session-Termination Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_sta [ePDG:store_last_line $out1]
        
        if { [string match $sessionid_info_str $sessionid_info_sta] == 1 } {
            log.test "Session ID from STR & STA matches ; Verified STA"
        } else {
            error.an "Session ID from STR & STA does not match"
        }
        
    }
    
    runStep "Verify the Diameter Result in STA" {
       
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
    
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aar_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "Stats Verified"            
        } else {
            error.an "Unable to verify stats"
        }
        
    }
        
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section2:S6B:C226250:C226257
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/29/2016
set pctComp   100
set summary   "This test verifies that AAA initates the termination with authentication session state as NO_STATE_MAINTAINED && No STR triggered during termintaion when auth session state in AAR response is NO_STATE_MAINTAINED"
set descr     "
1.  Clear any previous sessions and Stop the AAA Server
2.  Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the AAA initiated session termination timer as 20 sec
3.  Change the AUTH_STATE to 1 \( NO_STATE_MAINTAINED \) in s6bserver python script
4.  Start the Packetcapture & Bring up the session
5.  Decode TCP Packets as DIAMETER and Import Packet info ; Check if There is NO STR sent
6.  Verify the Authorization State in AA Answer to be \"NO_STATE_MAINTAINED\"
7.  Verify the Diameter Result in ASR
8.  Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear any previous sessions and Stop the AAA Server" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        s6b stop
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_before [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aar_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_asr_request [cmd_out . values.num-asr-request-received]
        
    }
    
    runStep "Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the AAA initiated session termination timer as 20 sec" {
       
        s6b data set "SessCloseNumTimeSlots 2"
                
    }
    
    runStep "Change the AUTH_STATE to 1 \( NO_STATE_MAINTAINED \) in s6bserver python script" {
        
        s6b configure -server s6bserver2
        s6b init
        sleep 5
                        
    }
    
    runStep "Start the Packetcapture & Bring up the session" {
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        sleep 25
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
     runStep "Decode TCP Packets as DIAMETER and Import Packet info ; Check if There is NO STR sent" {
        
        set packet_info [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"]
        
        if { ![regexp.an "Session-TerminationRequest" $packet_info] } {
            log.test "NO STR Found"
        } else {
            error.an "STR Found ; Check the python script and try again"
        }
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }
    
     runStep "Verify the Authorization State in AA Answer to be \"NO_STATE_MAINTAINED\"" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Auth-Session-State\" showname=\"Auth-Session-State:' | sed -n '2p'"]
        set auth_state_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Auth-Session-State:\s([A-Z_]+)} $auth_state_info - auth_state
        
        if { [string match $auth_state "NO_STATE_MAINTAINED"] == 1 } {
            log.test "Authorization State Verified"
        } else {
            error.an "Authorization State does not match ; Authorization State is $auth_state ; Expected is NO_STATE_MAINTAINED"
        }
        
    }
    
    runStep "Verify the Diameter Result in ASR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Abort-Session Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
                        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - $diameter_result ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
    
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_after [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { $s6b_close_attempts_after == [expr $s6b_close_attempts_before +1] && [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aar_attempt +1 ] && [cmd_out . values.num-asr-request-received] == [ expr $num_asr_request +1 ] } {
            log.test "Stats Verified"
        } else {
            error.an "Unable to verify Stats"
        }
       
    }    
        
} {
    # Cleanup
    s6b stop
    s6b configure -server [tb _ s6b.server]
    
    s6b data set "SessCloseNumTimeSlots 0"
    
    s6b init
    sleep 5
        
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section2:S6B:C226251:C226253
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/29/2016
set pctComp   100
set summary   "This test verifies that AAA initates the termination with authentication session state as STATE_MAINTAINED && Verify Stats"
set descr     "
1.  Clear any previous sessions and Stop the AAA Server
2.  Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the AAA initiated session termination timer as 20 sec
4.  Start the Packetcapture & Bring up the session
5.  Decode TCP Packets as DIAMETER and Import Packet info
6.  Verify the Authorization State in AA Answer to be \"STATE_MAINTAINED\"
7.  Verify the Termination cause in STR is DIAMETER_ADMINISTRATIVE
8.  Verify the Diameter Result in ASR
9.  Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear any previous sessions and Stop the AAA Server ; Record the Stats" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        s6b stop
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_before [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aar_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
        
    }
    
    runStep "Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the AAA initiated session termination timer as 20 sec" {
        
        s6b data set "SessCloseNumTimeSlots 2"
        
        s6b configure -server [tb _ s6b.server]
        s6b init
        sleep 5
                
    }
    
    runStep "Start the Packetcapture & Bring up the session" {
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        sleep 25
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
     runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }
    
     runStep "Verify the Authorization State in AA Answer to be \"STATE_MAINTAINED\"" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Auth-Session-State\" showname=\"Auth-Session-State:' | sed -n '1p'"]
        set auth_state_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Auth-Session-State:\s([A-Z_]+)} $auth_state_info - auth_state
        
        if { [string match $auth_state "STATE_MAINTAINED"] == 1 } {
            log.test "Authorization State Verified"
        } else {
            error.an "Authorization State does not match ; Authorization State is $auth_state ; Expected is STATE_MAINTAINED"
        }
        
    }
    
    runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause "DIAMETER_ADMINISTRATIVE"] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Termination Cause is $termination_cause ; Expected is DIAMETER_ADMINISTRATIVE"
        }
        
    }  
    
    runStep "Verify the Diameter Result in ASR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Abort-Session Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
                        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - $diameter_result ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
    
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_after [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { $s6b_close_attempts_after == [expr $s6b_close_attempts_before +1] && [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aar_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "Stats Verified"            
        } else {
            error.an "Unable to verify stats"
        }
        
    }
        
} {
    # Cleanup
    s6b stop
        
    s6b data set "SessCloseNumTimeSlots 0"
    
    s6b configure -server [tb _ s6b.server]
    s6b init
    sleep 5
        
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section2:S6B:C226387
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   8/31/2016
set pctComp   100
set summary   "This test verifies that UE initiates the session termination"
set descr     "
1.  Start the Packet Capture on GI interface and bring up the session ; Verify Data Path
2.  Terminate the Session from UE and Stop Packet capture
3.  Decode TCP Packets as DIAMETER and Import STR Packet info
4.  Verify the Termination cause in STR
5.  Verify the Diameter Result in STA
6.  Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Record the initial Stats ; Start the Packet Capture on GI interface and bring up the session ; Verify Data Path" {
        
        dut exec "subscriber clear"
        dut exec "subscriber clear-local"        
        ue exec "ipsec restart"
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aar_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
                
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
    }
    
    runStep "Terminate the Session from PGW and Stop Packet capture" {
        
        ue exec "ipsec restart"
        sleep 2
        ue exec "ipsec stop"                
        sleep 5
        
        set subscriber_info [dut exec "show subscriber summary"]
        
        if { [regexp.an " No entries found" $subscriber_info] } {
            log.test "Session Terminated by UE"
        } else {
            ue exec "ipsec restart"
            sleep 2
            ue exec "ipsec stop"
            sleep 5
        }
  
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import STR Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }    
   
    runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause "DIAMETER_LOGOUT"] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Expected is DIAMETER_LOGOUT"
        }
        
    }        
    
    runStep "Verify the Diameter Result in STA" {
       
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
    
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aar_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "Stats Verified"            
        } else {
            error.an "Unable to verify stats"
        }
        
    }
        
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section2:S6B:C226254:C226388:C226255
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   9/01/2016
set pctComp   100
set summary   "This test verifies that AAA server sends RAR, RAA followed by AAR is triggered && AAA server triggered RAR after initial AAR, the triggers ASR"
set descr     "
1.  Clear any previous sessions and Stop the AAA Server
2.  Change the 1st and 3rd  digit after Data Record corresponding to 2 and 4 respectively
4.  Start the Packetcapture & Bring up the session
5.  Decode TCP Packets as DIAMETER and Import Packet info
6.  Find out the session ID and username info from AAR and AAA
7.  Find out the session ID info from RAR
8.  Find out the session ID info and diameter response from RAA
9.  Find out the session ID and username info from 2nd AAR and AAA
10. Find out the session ID info from ASR
11. Find out the session ID info and Diameter response from ASA
12. Find out the session ID and username info from STR
13. Verify the Termination cause in STR
14. Find the session ID and Diameter response in STA
15. Verify the Diameter Result in 1st and 2nd AAAs, RAA, ASA and STA
16. Verify that same User name and Session IDs are present in RAR and 2nd AAR, AAA , ASA, STR and STA are equal
17. Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear any previous sessions and Stop the AAA Server ; Record the Stats" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        catch {s6b stop}
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_before [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aar_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]        
        set num_rar_request [cmd_out . values.num-rar-request-received]
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
        set num_asr_request [cmd_out . values.num-asr-request-received]
        set num_reauth_aar_success [cmd_out . values.num-server-initiated-reauth-aar-success]
        set num_reauth_aar_rcvd_attempt [cmd_out . values.num-server-initiated-reauth-aaa-rcvd-first-attempt]
        
    }
    
    runStep "Change the 1st and 3rd  digit after Data Record corresponding to 2 and 4 respectively" {
        
        s6b data set "QosUpdateNumTimeSlots 2"
        s6b data set "SessCloseNumTimeSlots 4"
        
        s6b configure -server [tb _ s6b.server]
        s6b init
        sleep 5
                
    }
    
    runStep "Start the Packetcapture & Bring up the session" {
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        sleep 50
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
     runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4        
        
    }
    
    runStep "Find out the session ID and username info from AAR and AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]        
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.User-Name\" showname=\"User-Name: ' | sed -n '1p'"]
        set username_info [ePDG:store_last_line $out1]
        regexp.an {\"User-Name:\s([_0-9.a-zA-Z:;-]+)} $username_info - username_aar1
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_aaa1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa1
        
    }
    
    runStep "Find out the session ID info from RAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Re-Auth Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]        
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_rar [ePDG:store_last_line $out1]
        
    }
    
     runStep "Find out the session ID info and diameter response from RAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Re-Auth Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]        
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_raa [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_raa
        
     }
     
    runStep "Find out the session ID and username info from 2nd AAR and AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]        
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_aar2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.User-Name\" showname=\"User-Name: ' | sed -n '1p'"]
        set username_info [ePDG:store_last_line $out1]
        regexp.an {\"User-Name:\s([_0-9.a-zA-Z:;-]+)} $username_info - username_aar2
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_aaa2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa2
        
    }
    
    runStep "Find out the session ID info from ASR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Abort-Session Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]        
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_asr [ePDG:store_last_line $out1]
        
    }
    
     runStep "Find out the session ID info and Diameter response from ASA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Abort-Session Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]        
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_asa [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_asa
        
     }     
          
         
    runStep "Find out the session ID and username info from STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.User-Name\" showname=\"User-Name: ' | sed -n '1p'"]
        set username_info [ePDG:store_last_line $out1]
        regexp.an {\"User-Name:\s([_0-9.a-zA-Z:;-]+)} $username_info - username_str
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_str [ePDG:store_last_line $out1]
        
    }
    
     runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause "DIAMETER_ADMINISTRATIVE"] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Expected is DIAMETER_ADMINISTRATIVE"
        }
        
    }        
    
    runStep "Find the session ID and Diameter response in STA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Session-Termination Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Session-Id\" showname=\"Session-Id: ' | sed -n '1p'"]
        set sessionid_info_sta [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_sta
    
    }
    
    runStep "Verify the Diameter Result in 1st and 2nd AAAs, RAA, ASA and STA" {       
        
        if { [string match $diameter_result_aaa1 "DIAMETER_SUCCESS"] && [string match $diameter_result_raa "DIAMETER_SUCCESS"] && [string match $diameter_result_aaa2 "DIAMETER_SUCCESS"] && [string match $diameter_result_asa "DIAMETER_SUCCESS"] && [string match $diameter_result_sta "DIAMETER_SUCCESS"] } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - AAA1 - $diameter_result_aaa1 ; RAA - $diameter_result_raa ; AAA2 - $diameter_result_aaa2 ; ASA - $diameter_result_asa ; STA - $diameter_result_sta ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify that same User name and Session IDs are present in RAR and 2nd AAR, AAA , ASA, STR and STA are equal" {
        
        if { [string match $username_aar1 $username_aar2] && [string match $username_aar1 $username_str] } {
            log.test "Usernames matched"
        } else {
            error.an "Usernames do not match"
        }
        
        if { [string match $sessionid_info_aaa1 $sessionid_info_rar] && [string match $sessionid_info_aaa1 $sessionid_info_raa] && [string match $sessionid_info_aaa1 $sessionid_info_aar2] && [string match $sessionid_info_aaa1 $sessionid_info_aaa2] && [string match $sessionid_info_aaa1 $sessionid_info_asr] && [string match $sessionid_info_aaa1 $sessionid_info_asa] && [string match $sessionid_info_aaa1 $sessionid_info_str] && [string match $sessionid_info_aaa1 $sessionid_info_sta] } {
            log.test "Session IDS from all messages verified"            
        } else {
            error.an "Unable to verify session IDs ; All are expected to be same"
        }
        
    }
    
    runStep "Verify the Stats" {
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_after [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
    
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { $s6b_close_attempts_after == [expr $s6b_close_attempts_before +1] && [cmd_out . values.num-rar-request-received] == [expr $num_rar_request +1] && [cmd_out . values.num-asr-request-received] == [ expr $num_asr_request +1 ] && [cmd_out . values.num-server-initiated-reauth-aaa-rcvd-first-attempt] == [expr $num_reauth_aar_rcvd_attempt +1] && [cmd_out . values.num-server-initiated-reauth-aar-success] == [expr $num_reauth_aar_success +1] && [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aar_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "Stats Verified"            
        } else {
            error.an "Unable to verify stats"
        }
         
    }
        
} {
    # Cleanup
    s6b stop
        
    s6b data set "QosUpdateNumTimeSlots 0"
    s6b data set "SessCloseNumTimeSlots 0"
    
    s6b init
    sleep 5
        
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section2:S6B:C461149
} else {
	set id        ePDG:section2:S6B:C461150:C321152
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   9/07/2016
set pctComp   100
set summary   "This Test verifies IPV4 and IPV6 only Handoffs from non-3gpp to 3gpp when access type is non_3gpp_access_only and authentication session state as STATE_MAINTAINED"
set descr     "
1.  Clear any previous sessions ; Record the Stats
2.  Change the Access type to non_3gpp_access_only for S6B interface
3.  Call Handover Procedure , terminate the session and Import Packet Capture
4.  Decode TCP Packets as DIAMETER and Import Packet info
5.  Find and Verify the RAT Type in AAR
6.  Find the Diameter response in AAA
7.  Verify the Termination cause in STR
8.  Find the Diameter response in STA
9.  Verify the Diameter Result in AAA and STA
10. Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
	
    runStep "Clear any previous sessions and Stop the AAA Server ; Record the Stats" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aaa_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]        
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
    }
    
    runStep "Change the Access type to non_3gpp_access_only for S6B interface and start the Packet capture" {

        set out [dut exec "show running-config service-construct interface s6b-interface S6b_INTF access-type"]
        
        regexp.an -lineanchor {^\s*access-type\s+([-a-z0-9]+)$} $out - access_type

        if { [string match $access_type "non-3gpp-only"] } {
            puts "Access Type Set to non-3gpp"
        } else {
            dut exec config "service-construct interface s6b-interface S6b_INTF access-type non-3gpp-only"
            dut exec config "commit"       
        }
    
		dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
	
    }
    
    runStep "Call Handover Procedure , terminate the session and Import Packet Capture" {
        
        if { $i == 0 } {
            ePDG:V4_handover_non3gpp_to_3gpp            
        } else {
            ePDG:V6_handover_non3gpp_to_3gpp
        }
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file    
        
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4        
        
    }
    
     runStep "Find and Verify the RAT Type in AAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.RAT-Type\" showname=\"RAT-Type: ' | sed -n '1p'"]
        set rat_type_info [ePDG:store_last_line $out1]
        
        regexp.an {\"RAT-Type:\s([A-Z_]+)} $rat_type_info - rat_type
        
        if { [string match $rat_type "VIRTUAL"] == 1 } {
            log.test "RAT Type Verified"
        } else {
            error.an "RAT Type does not match ; Expected is VIRTUAL for non-3gpp session"
        }
    
    }
    
    runStep "Find the Diameter response in AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa
    
    }
    
    runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause "DIAMETER_USER_MOVED"] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Expected is DIAMETER_USER_MOVED"
        }
        
    }
    
     runStep "Find the Diameter response in STA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Session-Termination Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_sta
    
    }
    
     runStep "Verify the Diameter Result in AAA and STA" {       
        
        if { [string match $diameter_result_aaa "DIAMETER_SUCCESS"] && [string match $diameter_result_sta "DIAMETER_SUCCESS"] } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - AAA - $diameter_result_aaa ; STA - $diameter_result_sta ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aaa_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "S6b Stats Verified"            
        } else {
            error.an "Unable to verify S6b stats"
        }
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    dut exec config "service-construct interface s6b-interface S6b_INTF access-type both-non3gpp-and-3gpp"
    dut exec config "commit"
    
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
	trans config
    
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section2:S6B:C461151
} else {
	set id        ePDG:section2:S6B:C461152
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   9/08/2016
set pctComp   100
set summary   "This Test verifies IPV4 and IPV6 only Handoffs from non-3gpp to 3gpp when access type is non_3gpp_access_only and authentication session state as NO_STATE_MAINTAINED"
set descr     "
1.  Configure S6b server for authentication session state as NO_STATE_MAINTAINED
2.  Clear any previous sessions ; Record the Stats
3.  Change the Access type to non_3gpp_access_only for S6B interface
4.  Call Handover Procedure , terminate the session and Import Packet Capture
5.  Decode TCP Packets as DIAMETER and Import Packet info
6.  Find and Verify the RAT Type in AAR
7.  Find the Diameter response in AAA
8.  Verify the Diameter Result in AAA
9.  Verify the Stats"
    
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
	
    runStep "Configure S6b server for authentication session state as NO_STATE_MAINTAINED" {
    
        s6b stop
        s6b configure -server s6bserver2
        s6b init
        sleep 5
        
    }
    
    runStep "Clear any previous sessions and Stop the AAA Server ; Record the Stats" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aaa_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]        
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
    }
    
    runStep "Change the Access type to non_3gpp_access_only for S6B interface and start the Packet capture" {

        set out [dut exec "show running-config service-construct interface s6b-interface S6b_INTF access-type"]
        
        regexp.an -lineanchor {^\s*access-type\s+([-a-z0-9]+)$} $out - access_type

        if { [string match $access_type "non-3gpp-only"] } {
            puts "Access Type Set to non-3gpp"
        } else {
            dut exec config "service-construct interface s6b-interface S6b_INTF access-type non-3gpp-only"
            dut exec config "commit"       
        }
    
		dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
	
    }
    
    runStep "Call Handover Procedure , terminate the session and Import Packet Capture" {
        
        if { $i == 0 } {
            ePDG:V4_handover_non3gpp_to_3gpp            
        } else {
            ePDG:V6_handover_non3gpp_to_3gpp
        }
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file    
        
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4        
        
    }
    
     runStep "Find and Verify the RAT Type in AAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.RAT-Type\" showname=\"RAT-Type: ' | sed -n '1p'"]
        set rat_type_info [ePDG:store_last_line $out1]
        
        regexp.an {\"RAT-Type:\s([A-Z_]+)} $rat_type_info - rat_type
        
        if { [string match $rat_type "VIRTUAL"] == 1 } {
            log.test "RAT Type Verified"
        } else {
            error.an "RAT Type does not match ; Expected is VIRTUAL for non-3gpp session"
        }
    
    }
    
    runStep "Find the Diameter response in AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa
    
    }    
  
    runStep "Verify the Diameter Result in AAA" {       
        
        if { [string match $diameter_result_aaa "DIAMETER_SUCCESS"] } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - AAA - $diameter_result_aaa ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aaa_attempt +1 ] } {
            log.test "S6b Stats Verified"            
        } else {
            error.an "Unable to verify S6b stats"
        }
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
       
    }
    
} {
    # Cleanup
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    dut exec config "service-construct interface s6b-interface S6b_INTF access-type both-non3gpp-and-3gpp"
    dut exec config "commit"
    
    s6b stop
    s6b configure -server [tb _ s6b.server]
    s6b init
    sleep 5
    
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
	trans config
    
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section2:S6B:C461153
} else {
	set id        ePDG:section2:S6B:C461154:C321165
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   9/08/2016
set pctComp   100
set summary   "This Test verifies IPV4 and IPV6 only Handoffs from non-3gpp to 3gpp when access type is both-non3gpp-and-3gpp and authentication session state as STATE_MAINTAINED"
set descr     "
1.  Clear any previous sessions ; Record the Stats
2.  Change the Access type to both-non3gpp-and-3gpp for S6B interface
3.  Call Handover Procedure , terminate the session and Import Packet Capture
4.  Decode TCP Packets as DIAMETER and Import Packet info
5.  Find and Verify the RAT Type in Non-3gpp AAR
6.  Find the Diameter response in Non-3gpp AAA
7.  Find and Verify the RAT Type in 3gpp AAR
8.  Find the Diameter response in 3gpp AAA
9.  Verify the Termination cause in STR
10. Find the Diameter response in STA
11. Verify the Diameter Result in AAAs and STA
12. Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
	
    runStep "Clear any previous sessions and Stop the AAA Server ; Record the Stats" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]        
        set num_aaa_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_handoff_aaa_rcvd [cmd_out . values.num-handoff-aaa-rcvd-first-attempt]
        set num_handoff_aar_success [cmd_out . values.num-handoff-aar-success]
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
       
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
    }
    
    runStep "Change the Access type to both-non3gpp-and-3gpp for S6B interface and start the Packet capture" {

        set out [dut exec "show running-config service-construct interface s6b-interface S6b_INTF access-type"]
        
        regexp.an -lineanchor {^\s*access-type\s+([-a-z0-9]+)$} $out - access_type

        if { [string match $access_type "both-non3gpp-and-3gpp"] } {
            puts "Access Type Set to both 3gpp_and_non_3gpp"
        } else {
            dut exec config "service-construct interface s6b-interface S6b_INTF access-type both-non3gpp-and-3gpp"
            dut exec config "commit"       
        }
    
		dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
	
    }
    
    runStep "Call Handover Procedure , terminate the session and Import Packet Capture" {
       
        if { $i == 0 } {
            ePDG:V4_handover_non3gpp_to_3gpp            
        } else {
            ePDG:V6_handover_non3gpp_to_3gpp
        }
        
        catch {trans terminateCall}
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        sleep 2
            
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file    
        
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4        
        
    }
    
     runStep "Find and Verify the RAT Type in Non-3gpp AAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.RAT-Type\" showname=\"RAT-Type: ' | sed -n '1p'"]
        set rat_type_info [ePDG:store_last_line $out1]
        
        regexp.an {\"RAT-Type:\s([A-Z_]+)} $rat_type_info - rat_type
        
        if { [string match $rat_type VIRTUAL] == 1 } {
            log.test "RAT Type Verified"
        } else {
            error.an "RAT Type does not match ; Expected is VIRTUAL for non-3gpp session"
        }
    
    }
    
    runStep "Find the Diameter response in Non-3gpp AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa1
    
    }
    
    runStep "Find and Verify the RAT Type in 3gpp AAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.RAT-Type\" showname=\"RAT-Type: ' | sed -n '1p'"]
        set rat_type_info [ePDG:store_last_line $out1]
        
        regexp.an {\"RAT-Type:\s([A-Z_]+)} $rat_type_info - rat_type
        
        if { [string match $rat_type EUTRAN] == 1 } {
            log.test "RAT Type Verified"
        } else {
            error.an "RAT Type $rat_type does not match ; Expected is EUTRAN for 3gpp session"
        }
    
    }
    
    runStep "Find the Diameter response in 3gpp AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa2
    
    }
    
    runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause DIAMETER_LOGOUT] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Expected is DIAMETER_LOGOUT"
        }
        
    }
    
     runStep "Find the Diameter response in STA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Session-Termination Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_sta
    
    }
    
     runStep "Verify the Diameter Result in AAAs and STA" {       
        
        if { [string match $diameter_result_aaa1 "DIAMETER_SUCCESS"] && [string match $diameter_result_sta "DIAMETER_SUCCESS"] && [string match $diameter_result_aaa2 "DIAMETER_SUCCESS"] } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - AAA1 - $diameter_result_aaa1 ; STA - $diameter_result_sta ; AAA2 - $diameter_result_aaa2 ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { [cmd_out . values.num-handoff-aar-success] == [ expr $num_handoff_aar_success +1 ] && [cmd_out . values.num-handoff-aaa-rcvd-first-attempt] == [ expr $num_handoff_aaa_rcvd +1 ] && [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aaa_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "S6b Stats Verified"            
        } else {
            error.an "Unable to verify S6b stats"
        }
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    dut exec config "service-construct interface s6b-interface S6b_INTF access-type both-non3gpp-and-3gpp"
    dut exec config "commit"
    
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
	trans config
    trans init
    
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section2:S6B:C461155
} else {
	set id        ePDG:section2:S6B:C461156:C321164
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   9/09/2016
set pctComp   100
set summary   "This Test verifies IPV4 and IPV6 only Handoffs from 3gpp to non-3gpp when access type is both-non3gpp-and-3gpp and authentication session state as STATE_MAINTAINED"
set descr     "
1.  Clear any previous sessions ; Record the Stats
2.  Change the Access type to both-non3gpp-and-3gpp for S6B interface
3.  Call Handover Procedure , terminate the session and Import Packet Capture
4.  Decode TCP Packets as DIAMETER and Import Packet info
5.  Find and Verify the RAT Type in 3gpp AAR
6.  Find the Diameter response in 3gpp AAA
7.  Find and Verify the RAT Type in Non-3gpp AAR
8.  Find the Diameter response in Non-3gpp AAA
9.  Verify the Termination cause in STR
10. Find the Diameter response in STA
11. Verify the Diameter Result in AAAs and STA
12. Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
	
    runStep "Clear any previous sessions and Stop the AAA Server ; Record the Stats" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]        
        set num_aaa_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_handoff_aaa_rcvd [cmd_out . values.num-handoff-aaa-rcvd-first-attempt]
        set num_handoff_aar_success [cmd_out . values.num-handoff-aar-success]
        set num_str_success [cmd_out . values.num-str-success]
        set num_sta_attempt [cmd_out . values.num-sta-rcvd-first-attempt]
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsBefore
        
    }
    
    runStep "Change the Access type to both-non3gpp-and-3gpp for S6B interface and start the Packet capture" {

        set out [dut exec "show running-config service-construct interface s6b-interface S6b_INTF access-type"]
        
        regexp.an -lineanchor {^\s*access-type\s+([-a-z0-9]+)$} $out - access_type

        if { [string match $access_type "both-non3gpp-and-3gpp"] } {
            puts "Access Type Set to both 3gpp_and_non_3gpp"
        } else {
            dut exec config "service-construct interface s6b-interface S6b_INTF access-type both-non3gpp-and-3gpp"
            dut exec config "commit"       
        }
    
		dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
	
    }
    
    runStep "Call Handover Procedure , terminate the session and Import Packet Capture" {
       
        if { $i == 0 } {
            ePDG:V4_handover_3gpp_to_non3gpp            
        } else {
            ePDG:V6_handover_3gpp_to_non3gpp
        }
        
        catch {trans terminateCall}
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        sleep 2
            
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file    
        
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4        
        
    }
    
    runStep "Find and Verify the RAT Type in 3gpp AAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.RAT-Type\" showname=\"RAT-Type: ' | sed -n '1p'"]
        set rat_type_info [ePDG:store_last_line $out1]
        
        regexp.an {\"RAT-Type:\s([A-Z_]+)} $rat_type_info - rat_type
        
        if { [string match $rat_type "EUTRAN"] == 1 } {
            log.test "RAT Type Verified"
        } else {
            error.an "RAT Type $rat_type does not match ; Expected is EUTRAN for 3gpp session"
        }
    
    }
    
    runStep "Find the Diameter response in 3gpp AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa1
    
    }
    
     runStep "Find and Verify the RAT Type in Non-3gpp AAR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'AA Request' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.RAT-Type\" showname=\"RAT-Type: ' | sed -n '1p'"]
        set rat_type_info [ePDG:store_last_line $out1]
        
        regexp.an {\"RAT-Type:\s([A-Z_]+)} $rat_type_info - rat_type
        
        if { [string match $rat_type "VIRTUAL"] == 1 } {
            log.test "RAT Type Verified"
        } else {
            error.an "RAT Type does not match ; Expected is VIRTUAL for non-3gpp session"
        }
    
    }
    
    runStep "Find the Diameter response in Non-3gpp AAA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_aaa2
    
    }   
    
    runStep "Verify the Termination cause in STR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Session-Termination Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Termination-Cause\" showname=\"Termination-Cause: ' | sed -n '1p'"]
        set termination_cause_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Termination-Cause:\s([A-Z_]+)} $termination_cause_info - termination_cause
        
        if { [string match $termination_cause "DIAMETER_LOGOUT"] == 1 } {
            log.test "Termination Cause Verified"
        } else {
            error.an "Termination cause does not match ; Expected is DIAMETER_LOGOUT"
        }
        
    }
    
     runStep "Find the Diameter response in STA" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'Session-Termination Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result_sta
    
    }
    
     runStep "Verify the Diameter Result in AAAs and STA" {       
        
        if { [string match $diameter_result_aaa1 "DIAMETER_SUCCESS"] && [string match $diameter_result_sta "DIAMETER_SUCCESS"] && [string match $diameter_result_aaa2 "DIAMETER_SUCCESS"] } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - AAA1 - $diameter_result_aaa1 ; STA - $diameter_result_sta ; AAA2 - $diameter_result_aaa2 ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify the Stats" {
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { [cmd_out . values.num-handoff-aar-success] == [ expr $num_handoff_aar_success +1 ] && [cmd_out . values.num-handoff-aaa-rcvd-first-attempt] == [ expr $num_handoff_aaa_rcvd +1 ] && [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aaa_attempt +1 ] && [cmd_out . values.num-str-success] == [ expr $num_str_success +1 ] && [cmd_out . values.num-sta-rcvd-first-attempt] == [ expr $num_sta_attempt +1 ] } {
            log.test "S6b Stats Verified"            
        } else {
            error.an "Unable to verify S6b stats"
        }
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsAfter
		
		if { $toNon3gppHoStatsAfter == [ expr $toNon3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    catch {trans terminateCall}
    ePDG:checkSessionState
    ue exec "cp /etc/ipsec.conf.antaf /etc/ipsec.conf"
    ue exec "ipsec restart"
    dut exec config "service-construct interface s6b-interface S6b_INTF access-type both-non3gpp-and-3gpp"
    dut exec config "commit"
    
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
	trans config
    
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section3:S2B:C529850:C776818
} else {
	set id        ePDG:section3:S2B:C529851:C212248
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/10/2016
set pctComp   100
set summary   "This Test verifies that UE attach first via s2b then handovers to S5/s8 - 2 APNs - with IPv4/IPv6 data"
set descr     "
1.  Record the Stats before Handover and Disable the PCRF Interface
2.  Start the Packet Capture ; Bring up and Handover the sessions
3.  Find the GTP-C Tunnel endpoint IP addresses
4.  Verify S2b and S5/S8 Interface Type and Code from the Packet capture
5.  Verify RAT Type before and after the Handover
6.  Verify S2b and S5/S8 Interface Stats
7.  Verify the Handover Stats"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
     runStep "Record the Stats before Handover and Disable the PCRF Interface" {
    
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
        set pgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $pgwStats1 - csa_pgw1
        regexp.an -lineanchor {^\s*saegw-pgw-current-sessions-eutran\s+([0-9]+)$} $pgwStats1 - pcse_pgw1
        
        set epdgStats1 [dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $epdgStats1 - a1 csa_epdg1        
        
        set sgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats1 - csa_sgw1
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats1 - mba_sgw1
        regexp.an -lineanchor {^\s*saegw-sgw-current-pdn-connections-eutran\s+([0-9]+)$} $sgwStats1 - scpce_sgw1
        
        dut exec config "no workflow control-profile CONTROL-PROFILE-PGW default-pcrf-interface PCRF_CHRG"
        dut exec config "commit"
                
    }
    
    runStep "Start the Packet Capture ; Bring up and Handover the sessions" {        
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
       
        if { $i == 0 } {
            array set returnStats [ePDG:V4_handover_non3gpp_to_3gpp_2APNS]
            regexp.an -lineanchor {^\s*current-ipv4-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        } else {
            array set returnStats [ePDG:V6_handover_non3gpp_to_3gpp_2APNS]
            regexp.an -lineanchor {^\s*current-ipv6-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Find the GTP-C Tunnel endpoint IP addresses" {
        
        set out [dut exec "show running-config network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip3] } {
            log.test "SGW Loopback ip-address: $ip3"
        } else {
            error.an "Failed to retrieve SGW Loopback ip-address"
        }           
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Type and Code from the Packet capture" {
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 3
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 3
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set loop 3
        ePDG:verifyS5S8Interface $loop
        
        set loop 4
        ePDG:verifyS5S8Interface $loop
      
    }
    
    runStep "Verify RAT Type before and after the Handover" {
     
        for {set j 1} {$j < 3} {incr j} {
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]     
            
            set rat "Virtual "
            set ratCode "(7)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
            
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]   
            
            set rat "EUTRAN "
            set ratCode "(6)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        }        
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Stats" {
        
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $returnStats(pgwStats2) - csa_pgw2        
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $returnStats(epdgStats2) - a1 csa_epdg2
                
        set pgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]        
        regexp.an -lineanchor {^\s*saegw-pgw-current-sessions-eutran\s+([0-9]+)$} $pgwStats3 - pcse_pgw3
        
        set sgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats3 - csa_sgw3
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats3 - mba_sgw3
        regexp.an -lineanchor {^\s*saegw-sgw-current-pdn-connections-eutran\s+([0-9]+)$} $sgwStats3 - scpce_sgw3
        
        if { $csa_pgw2 == [ expr $csa_pgw1 +2 ] && $csa_sgw3 == [ expr $csa_sgw1 +2 ] && $mba_sgw3 == [ expr $mba_sgw1 +2 ] && $csa_epdg2 == [ expr $csa_epdg1 +2 ] && $scpce_sgw3 == 2 && $pcse_pgw3 == 2 && $cips_pgw2 == 2 } {
            log.test "S2b and S5/S8 Interface Stats Verified"            
        } else {
            error.an "Unable to verify S2b and S5/S8 Interface Stats"
        }
        
    }
    
    runStep "Verify the Handover Stats" {        
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +2 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
                
    }
    
} {
    # Cleanup
    dut exec config "workflow control-profile CONTROL-PROFILE-PGW default-pcrf-interface PCRF_CHRG"
    dut exec config "commit"
    
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
    ue2 data set "apn_info \"APN:[tb _ dut.apn1]\""
    ue2 data set "pdnip_apn1 \"PDNIPADDRESS:v4 0\""
    ue2 data set "pdnip_apn2 \"PDNIPADDRESS:v4 0\""
	trans config
        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section3:S2B:C529852:C776819
} else {
	set id        ePDG:section3:S2B:C529853:C212247
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/10/2016
set pctComp   100
set summary   "This Test verifies that UE attach first via S5/s8 then handovers to S2b - 2 APNs - with IPv4/IPv6 data"
set descr     "
1.  Record the Stats before Handover and Disable the PCRF Interface
2.  Start the Packet Capture ; Bring up and Handover the sessions
3.  Find the GTP-C Tunnel endpoint IP addresses
4.  Verify S2b and S5/S8 Interface Type and Code from the Packet capture
5.  Verify RAT Type before and after the Handover
6.  Verify S2b and S5/S8 Interface Stats
7.  Verify the Handover Stats"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Record the Stats before Handover and Disable the PCRF Interface" {
    
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsBefore
        
        set pgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $pgwStats1 - csa_pgw1
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $pgwStats1 - mba_pgw1
               
        set epdgStats1 [dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $epdgStats1 - a1 csa_epdg1
        
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats1 - cbatp_epdg1] == 0 } {
            set cbatp_epdg1 0
        }
        if { [regexp.an -lineanchor {^\s*create-session-accepts-from-pgw\s+([0-9]+)$} $epdgStats1 - csafp_epdg1] == 0 } {
            set csafp_epdg1 0
        }        
        
        regexp.an -lineanchor {^\s*initial-authentication-authorization-successes\s+([0-9]+)$} $epdgStats1 - iaas_epdg1
        regexp.an -lineanchor {^\s*eap-successes-received-from-aaa-server\s+([0-9]+)$} $epdgStats1 - esas_epdg1              
        
        set sgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats1 - csa_sgw1
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats1 - mba_sgw1
        
        dut exec config "no workflow control-profile CONTROL-PROFILE-PGW default-pcrf-interface PCRF_CHRG"
        dut exec config "commit"
            
    }
    
    runStep "Start the Packet Capture ; Bring up and Handover the sessions" {        
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
       
        if { $i == 0 } {
            array set returnStats [ePDG:V4_handover_3gpp_to_non3gpp_2APNS]
            regexp.an -lineanchor {^\s*current-ipv4-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        } else {
            array set returnStats [ePDG:V6_handover_3gpp_to_non3gpp_2APNS]
            regexp.an -lineanchor {^\s*current-ipv6-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Find the GTP-C Tunnel endpoint IP addresses" {
        
        set out [dut exec "show running-config network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip3] } {
            log.test "SGW Loopback ip-address: $ip3"
        } else {
            error.an "Failed to retrieve SGW Loopback ip-address"
        }           
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Type and Code from the Packet capture" {
        
        set loop 1
        ePDG:verifyS5S8Interface $loop
        
        set loop 2
        ePDG:verifyS5S8Interface $loop
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 5
        set init 3
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 5
        set init 3
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
      
    }
    
    runStep "Verify RAT Type before and after the Handover" {
     
        for {set j 1} {$j < 3} {incr j} {
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]     
            
            set rat "Virtual "
            set ratCode "(7)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
            
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]   
            
            set rat "EUTRAN "
            set ratCode "(6)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        }        
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Stats" {
        
        regexp.an -lineanchor {^\s*saegw-sgw-current-pdn-connections-eutran\s+([0-9]+)$} $returnStats(sgwStats2) - scpce_sgw2
        
        set pgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $pgwStats3 - csa_pgw3
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $pgwStats3 - mba_pgw3
        
        set epdgStats3 [dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $epdgStats3 - a1 csa_epdg3
        
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats3 - cbatp_epdg3] == 0 } {
            set cbatp_epdg3 2
        }
        if { [regexp.an -lineanchor {^\s*create-session-accepts-from-pgw\s+([0-9]+)$} $epdgStats3 - csafp_epdg3] == 0 } {
            set csafp_epdg3 2
        }
        
        regexp.an -lineanchor {^\s*initial-authentication-authorization-successes\s+([0-9]+)$} $epdgStats3 - iaas_epdg3
        regexp.an -lineanchor {^\s*eap-successes-received-from-aaa-server\s+([0-9]+)$} $epdgStats3 - esas_epdg3
        
        set sgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats3 - csa_sgw3
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats3 - mba_sgw3
                
        if { $csa_pgw3 == [ expr $csa_pgw1 +2 ] && $csa_sgw3 == [ expr $csa_sgw1 +2 ] && $mba_sgw3 == [ expr $mba_sgw1 +2 ] && $csa_epdg3 == [ expr $csa_epdg1 +2 ] && $csafp_epdg3 == [ expr $csafp_epdg1 +2 ] && $iaas_epdg3 == [ expr $iaas_epdg1 +2 ] && $esas_epdg3 == [ expr $esas_epdg1 +2 ] && $scpce_sgw2 == 2 && $cips_pgw2 == 2 } {
            log.test "S2b and S5/S8 Interface Stats Verified"            
        } else {
            error.an "Unable to verify S2b and S5/S8 Interface Stats"
        }
        #&& $mba_pgw3 == [ expr $mba_pgw1 +4 ] && $cbatp_epdg3 == [ expr $cbatp_epdg1 +2 ]
        
    }
    
    runStep "Verify the Handover Stats" {        
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsAfter
		
		if { $toNon3gppHoStatsAfter == [ expr $toNon3gppHoStatsBefore +2 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    dut exec config "workflow control-profile CONTROL-PROFILE-PGW default-pcrf-interface PCRF_CHRG"
    dut exec config "commit"
   
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
        
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
    ue2 data set "apn_info \"APN:[tb _ dut.apn1]\""
    ue2 data set "pdnip_apn1 \"PDNIPADDRESS:v4 0\""
    ue2 data set "pdnip_apn2 \"PDNIPADDRESS:v4 0\""
	trans config
        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section3:S2B:C529856:C212216:C212217
} else {
	set id        ePDG:section3:S2B:C529857:C775120:C775121
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/10/2016
set pctComp   100
set summary   "This Test verifies that UE attach first via s2b then handovers to S5/s8 - 2 dedicated bearers (1 Default Bearer)- with IPv4/IPv6 data"
set descr     "
1.  Record the Stats before Handover and Disable the PCRF Interface
2.  Start the Packet Capture ; Bring up and Handover the sessions
3.  Find the GTP-C Tunnel endpoint IP addresses
4.  Verify S2b and S5/S8 Interface Type and Code from the Packet capture
5.  Verify RAT Type before and after the Handover
6.  Verify S2b and S5/S8 Interface Stats
7.  Verify the Bearer Stats on MCC
8.  Verify the Handover Stats"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Record the Stats before Handover" {
    
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
        set pgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $pgwStats1 - csa_pgw1
        regexp.an -lineanchor {^\s*saegw-pgw-current-sessions-eutran\s+([0-9]+)$} $pgwStats1 - pcse_pgw1
        
        set epdgStats1 [dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $epdgStats1 - a1 csa_epdg1              
        set sgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats1 - csa_sgw1
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats1 - mba_sgw1
        regexp.an -lineanchor {^\s*saegw-sgw-current-pdn-connections-eutran\s+([0-9]+)$} $sgwStats1 - scpce_sgw1
          
    }
    
    runStep "Record the Bearer related Stats before Handover" {
        
        regexp.an -lineanchor {^\s*bearers-setup-success\s+([0-9]+)$} $sgwStats1 - bsc_sgw1
        regexp.an -lineanchor {^\s*create-bearer-accepts\s+([0-9]+)$} $sgwStats1 - cba_sgw1        
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats1 - cbap_epdg1] == 0 } {
            set cbap_epdg1 0
        }
        regexp.an -lineanchor {^\s*pgw-initiated-dedicated-bearer-activation-accepts\s+([0-9]+)$} $pgwStats1 - pidbaa_pgw1
    
    }
    
    runStep "Start the Packet Capture ; Bring up and Handover the sessions" {        
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
       
        if { $i == 0 } {
            array set returnStats [ePDG:V4_handover_non3gpp_to_3gpp]
            regexp.an -lineanchor {^\s*current-ipv4-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        } else {
            array set returnStats [ePDG:V6_handover_non3gpp_to_3gpp ]
            regexp.an -lineanchor {^\s*current-ipv6-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Find the GTP-C Tunnel endpoint IP addresses" {
        
        set out [dut exec "show running-config network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip3] } {
            log.test "SGW Loopback ip-address: $ip3"
        } else {
            error.an "Failed to retrieve SGW Loopback ip-address"
        }           
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Type and Code from the Packet capture" {
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set loop 2
        ePDG:verifyS5S8Interface $loop
       
    }
    
    runStep "Verify RAT Type before and after the Handover" {
     
        for {set j 1} {$j < 2} {incr j} {
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]     
            
            set rat "Virtual "
            set ratCode "(7)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
            
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]   
            
            set rat "EUTRAN "
            set ratCode "(6)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        }        
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Stats" {
        
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $returnStats(pgwStats2) - csa_pgw2        
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $returnStats(epdgStats2) - a1 csa_epdg2        
        set pgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]        
        regexp.an -lineanchor {^\s*saegw-pgw-current-sessions-eutran\s+([0-9]+)$} $pgwStats3 - pcse_pgw3
        
        set sgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats3 - csa_sgw3
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats3 - mba_sgw3
        regexp.an -lineanchor {^\s*saegw-sgw-current-pdn-connections-eutran\s+([0-9]+)$} $sgwStats3 - scpce_sgw3
        
        if { $csa_pgw2 == [ expr $csa_pgw1 +1 ] && $csa_sgw3 == [ expr $csa_sgw1 +1 ] && $mba_sgw3 == [ expr $mba_sgw1 +1 ] && $csa_epdg2 == [ expr $csa_epdg1 +1 ] && $scpce_sgw3 == 1 && $pcse_pgw3 == 1 && $cips_pgw2 == 1 } {
            log.test "S2b and S5/S8 Interface Stats Verified"            
        } else {
            error.an "Unable to verify S2b and S5/S8 Interface Stats"
        }
        
    }
    
    runStep "Verify the Bearer Stats on MCC" {        
        
        regexp.an -lineanchor {^\s*current-bearers-qci1\s+([0-9]+)$} $returnStats(pgwStats2) - cbq1_pgw2
        regexp.an -lineanchor {^\s*current-bearers-qci2\s+([0-9]+)$} $returnStats(pgwStats2) - cbq2_pgw2
                
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $returnStats(epdgStats2) - cbap_epdg2] == 0 } {
            set cbap_epdg2 1
        }
        
        regexp.an -lineanchor {^\s*current-bearers-qci1\s+([0-9]+)$} $pgwStats3 - cbq1_pgw3
        regexp.an -lineanchor {^\s*current-bearers-qci2\s+([0-9]+)$} $pgwStats3 - cbq2_pgw3
        regexp.an -lineanchor {^\s*pgw-initiated-dedicated-bearer-activation-accepts\s+([0-9]+)$} $pgwStats3 - pidbaa_pgw3
        
        regexp.an -lineanchor {^\s*bearers\s+([0-9]+)$} $pgwStats3 - bearers_pgw3
        regexp.an -lineanchor {^\s*default-bearers\s+([0-9]+)$} $pgwStats3 - db_pgw3
        regexp.an -lineanchor {^\s*dedicated-bearers\s+([0-9]+)$} $pgwStats3 - dedb_pgw3
        regexp.an -lineanchor {^\s*number-of-current-gx-sessions\s+([0-9]+)$} $pgwStats3 - ncgs_pgw3
        regexp.an -lineanchor {^\s*saegw-pgw-current-bearers\s+([0-9]+)$} $pgwStats3 - spcb_pgw3
        
        regexp.an -lineanchor {^\s*saegw-sgw-current-bearers\s+([0-9]+)$} $sgwStats3 - sscb_sgw3
        regexp.an -lineanchor {^\s*bearers-setup-success\s+([0-9]+)$} $sgwStats3 - bsc_sgw3
        regexp.an -lineanchor {^\s*create-bearer-accepts\s+([0-9]+)$} $sgwStats3 - cba_sgw3
        
        if { $cbap_epdg2 == [ expr $cbap_epdg1 +1 ] && $pidbaa_pgw3 == [ expr $pidbaa_pgw1 +1 ] && $bsc_sgw3 == [ expr $bsc_sgw1 +3 ] && $cba_sgw3 == [ expr $cba_sgw1 +1 ] &&
        $bearers_pgw3 == 3 && $db_pgw3 == 1 && $dedb_pgw3 == 2 && $ncgs_pgw3 == 1 && $spcb_pgw3 == 3 && $sscb_sgw3 == 3 } {
            log.test "Default & Dedicated Bearer Stats Verified"            
        } else {
            error.an "Unable to verify Default & Dedicated Bearer Stats"
        }
        
    }

    runStep "Verify the Handover Stats" {        
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
    ue2 data set "apn_info \"APN:[tb _ dut.apn1]\""
    ue2 data set "pdnip_apn1 \"PDNIPADDRESS:v4 0\""
    ue2 data set "pdnip_apn2 \"PDNIPADDRESS:v4 0\""
	trans config
        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section3:S2B:C529854
} else {
	set id        ePDG:section3:S2B:C529855
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/10/2016
set pctComp   100
set summary   "This Test verifies that UE attach first via S5/s8 then handovers to s2b - 2 dedicated bearers - with IPv4/IPv6 data"
set descr     "
1.  Record the Stats before Handover
2.  Start the Packet Capture ; Bring up and Handover the sessions
3.  Find the GTP-C Tunnel endpoint IP addresses
4.  Verify S2b and S5/S8 Interface Type and Code from the Packet capture
5.  Verify RAT Type before and after the Handover
6.  Verify S2b and S5/S8 Interface Stats
7.  Verify the Bearer Stats on MCC
8.  Verify the Handover Stats"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Record the Stats before Handover" {
    
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsBefore
        
        set pgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $pgwStats1 - csa_pgw1
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $pgwStats1 - mba_pgw1
               
        set epdgStats1 [dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $epdgStats1 - a1 csa_epdg1
        
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats1 - cbatp_epdg1] == 0 } {
            set cbatp_epdg1 0
        }
        if { [regexp.an -lineanchor {^\s*create-session-accepts-from-pgw\s+([0-9]+)$} $epdgStats1 - csafp_epdg1] == 0 } {
            set csafp_epdg1 0
        }
        
        regexp.an -lineanchor {^\s*initial-authentication-authorization-successes\s+([0-9]+)$} $epdgStats1 - iaas_epdg1
        regexp.an -lineanchor {^\s*eap-successes-received-from-aaa-server\s+([0-9]+)$} $epdgStats1 - esas_epdg1              
        
        set sgwStats1 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats1 - csa_sgw1
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats1 - mba_sgw1
            
    }
    
    runStep "Record the Bearer related Stats before Handover" {
        
        regexp.an -lineanchor {^\s*bearers-setup-success\s+([0-9]+)$} $sgwStats1 - bsc_sgw1
        regexp.an -lineanchor {^\s*create-bearer-accepts\s+([0-9]+)$} $sgwStats1 - cba_sgw1
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats1 - cbap_epdg1] == 0 } {
            set cbap_epdg1 0
        }
        regexp.an -lineanchor {^\s*pgw-initiated-dedicated-bearer-activation-accepts\s+([0-9]+)$} $pgwStats1 - pidbaa_pgw1
    
    }
    
    runStep "Start the Packet Capture ; Bring up and Handover the sessions" {
        
        trans init
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
       
        if { $i == 0 } {
            array set returnStats [ePDG:V4_handover_3gpp_to_non3gpp]
            regexp.an -lineanchor {^\s*current-ipv4-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        } else {
            array set returnStats [ePDG:V6_handover_3gpp_to_non3gpp]
            regexp.an -lineanchor {^\s*current-ipv6-pdn-sessions\s+([0-9]+)$} $returnStats(pgwStats2) - cips_pgw2
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Find the GTP-C Tunnel endpoint IP addresses" {
        
        set out [dut exec "show running-config network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip3] } {
            log.test "SGW Loopback ip-address: $ip3"
        } else {
            error.an "Failed to retrieve SGW Loopback ip-address"
        }           
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Type and Code from the Packet capture" {
        
        set loop 1
        ePDG:verifyS5S8Interface $loop
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 3
        set init 2
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 3
        set init 2
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
      
    }
    
    runStep "Verify RAT Type before and after the Handover" {
     
        for {set j 1} {$j < 2} {incr j} {
        
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]     
            
            set rat "Virtual "
            set ratCode "(7)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
            
            set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
            set frameNumber [ePDG:store_last_line $out1]   
            
            set rat "EUTRAN "
            set ratCode "(6)"
            ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        }        
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Stats" {
        
        regexp.an -lineanchor {^\s*saegw-sgw-current-pdn-connections-eutran\s+([0-9]+)$} $returnStats(sgwStats2) - scpce_sgw2
        
        set pgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance pgw PGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $pgwStats3 - csa_pgw3
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $pgwStats3 - mba_pgw3
        
        set epdgStats3 [dut exec "show zone default gateway statistics cluster-level call-performance epdg EPDG-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create([-a-z]+)accepts\s+([0-9]+)$} $epdgStats3 - a1 csa_epdg3
        
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats3 - cbatp_epdg3] == 0 } {
            set cbatp_epdg3 1
        }
        if { [regexp.an -lineanchor {^\s*create-session-accepts-from-pgw\s+([0-9]+)$} $epdgStats3 - csafp_epdg3] == 0 } {
            set csafp_epdg3 1
        }
        
        regexp.an -lineanchor {^\s*initial-authentication-authorization-successes\s+([0-9]+)$} $epdgStats3 - iaas_epdg3
        regexp.an -lineanchor {^\s*eap-successes-received-from-aaa-server\s+([0-9]+)$} $epdgStats3 - esas_epdg3
        
        set sgwStats3 [dut exec "show zone default gateway statistics cluster-level call-performance sgw SGW-1 [tb _ dut.chassisNumber]"]
        regexp.an -lineanchor {^\s*create-session-accepts\s+([0-9]+)$} $sgwStats3 - csa_sgw3
        regexp.an -lineanchor {^\s*modify-bearer-accepts\s+([0-9]+)$} $sgwStats3 - mba_sgw3
                
        if { $csa_pgw3 == [ expr $csa_pgw1 +1 ] && $mba_pgw3 == [ expr $mba_pgw1 +1 ] && $csa_sgw3 == [ expr $csa_sgw1 +1 ] && $mba_sgw3 == [ expr $mba_sgw1 +1 ] && $csa_epdg3 == [ expr $csa_epdg1 +1 ] && $cbatp_epdg3 == [ expr $cbatp_epdg1 +1 ] && $csafp_epdg3 == [ expr $csafp_epdg1 +1 ] && $iaas_epdg3 == [ expr $iaas_epdg1 +1 ] && $esas_epdg3 == [ expr $esas_epdg1 +1 ] && $scpce_sgw2 == 1 && $cips_pgw2 == 1 } {
            log.test "S2b and S5/S8 Interface Stats Verified"            
        } else {
            error.an "Unable to verify S2b and S5/S8 Interface Stats"
        }
        #&& $mba_pgw3 == [ expr $mba_pgw1 +4 ]
        
    }
    
    runStep "Verify the Bearer Stats on MCC" {        
        
        regexp.an -lineanchor {^\s*current-bearers-qci1\s+([0-9]+)$} $returnStats(pgwStats2) - cbq1_pgw2
        regexp.an -lineanchor {^\s*current-bearers-qci2\s+([0-9]+)$} $returnStats(pgwStats2) - cbq2_pgw2
        
        if { [regexp.an -lineanchor {^\s*create-bearer-accepts-to-pgw\s+([0-9]+)$} $epdgStats3 - cbap_epdg3] == 0 } {
            set cbap_epdg3 1
        }
        
        regexp.an -lineanchor {^\s*current-bearers-qci1\s+([0-9]+)$} $pgwStats3 - cbq1_pgw3
        regexp.an -lineanchor {^\s*current-bearers-qci2\s+([0-9]+)$} $pgwStats3 - cbq2_pgw3
        regexp.an -lineanchor {^\s*pgw-initiated-dedicated-bearer-activation-accepts\s+([0-9]+)$} $pgwStats3 - pidbaa_pgw3
        
        regexp.an -lineanchor {^\s*bearers\s+([0-9]+)$} $pgwStats3 - bearers_pgw3
        regexp.an -lineanchor {^\s*default-bearers\s+([0-9]+)$} $pgwStats3 - db_pgw3
        regexp.an -lineanchor {^\s*dedicated-bearers\s+([0-9]+)$} $pgwStats3 - dedb_pgw3
        regexp.an -lineanchor {^\s*number-of-current-gx-sessions\s+([0-9]+)$} $pgwStats3 - ncgs_pgw3
        regexp.an -lineanchor {^\s*saegw-pgw-current-bearers\s+([0-9]+)$} $returnStats(pgwStats2) - spcb_pgw2
        
        regexp.an -lineanchor {^\s*saegw-sgw-current-bearers\s+([0-9]+)$} $returnStats(sgwStats2) - sscb_sgw2
        regexp.an -lineanchor {^\s*bearers-setup-success\s+([0-9]+)$} $returnStats(sgwStats2) - bsc_sgw2
        regexp.an -lineanchor {^\s*create-bearer-accepts\s+([0-9]+)$} $returnStats(sgwStats2) - cba_sgw2
        
        if { $cbap_epdg3 == [ expr $cbap_epdg1 +1 ] && $pidbaa_pgw3 == [ expr $pidbaa_pgw1 +1 ] && $bsc_sgw2 == [ expr $bsc_sgw1 +3 ] && $cba_sgw2 == [ expr $cba_sgw1 +1 ] &&
        $bearers_pgw3 == 3 && $db_pgw3 == 1 && $dedb_pgw3 == 2 && $ncgs_pgw3 == 1 && $spcb_pgw2 == 3 && $sscb_sgw2 == 3 } {
            log.test "Default & Dedicated Bearer Stats Verified"            
        } else {
            error.an "Unable to verify Default & Dedicated Bearer Stats"
        }
        
    }

    runStep "Verify the Handover Stats" {        
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsAfter
		
		if { $toNon3gppHoStatsAfter == [ expr $toNon3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
        
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
    ue2 data set "apn_info \"APN:[tb _ dut.apn1]\""
    ue2 data set "pdnip_apn1 \"PDNIPADDRESS:v4 0\""
    ue2 data set "pdnip_apn2 \"PDNIPADDRESS:v4 0\""
	trans config
    trans init
        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section3:S2B:C529858
} else {
	set id        ePDG:section3:S2B:C529859
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/26/2016
set pctComp   100
set summary   "This Test verifies that UE attach first via s2b then handovers to S5/s8 then handover back to s2b - with IPv4/IPv6 data"
set descr     "
1.  Record the Stats before Handover and Disable the PCRF Interface
2.  Start the Packet Capture ; Bring up and Handover the sessions
3.  Find the GTP-C Tunnel endpoint IP addresses
4.  Verify S2b and S5/S8 Interface Type and Code from the Packet capture
5.  Verify RAT Type before and after the Handover
6.  Verify S2b and S5/S8 Interface Stats
7.  Verify the Handover Stats"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Record the Stats before Handover" {
    
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
        set out [dut exec "show zone default gateway statistics procedure-duration sgw SGW-1 create-session | notab | include count"]
        array set originalStats2 [ePDG:statsBeforeHandover $out]
        
        set out [dut exec "show zone default gateway statistics procedure-duration sgw SGW-1 modify-bearer-request | notab | include count"]
        array set originalStats3 [ePDG:statsBeforeHandover $out]
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsBefore
        
        set out [dut exec "show zone default gateway statistics procedure-duration pgw PGW-1 create-session | notab | include count"]
        array set originalStats5 [ePDG:statsBeforeHandover $out]
                
    }
    
    runStep "Start the Packet Capture ; Bring up and Handover the sessions" {
        
        trans init
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
       
        if { $i == 0 } {            
            array set returnStats [ePDG:v4HandoverNon3gppTo3gppToNon3gpp]            
        } else {
            array set returnStats [ePDG:v6HandoverNon3gppTo3gppToNon3gpp]            
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Find the GTP-C Tunnel endpoint IP addresses" {
        
        set out [dut exec "show running-config network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip3] } {
            log.test "SGW Loopback ip-address: $ip3"
        } else {
            error.an "Failed to retrieve SGW Loopback ip-address"
        }           
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Type and Code from the Packet capture" {
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set loop 2
        ePDG:verifyS5S8Interface $loop
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 4
        set init 3
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 4
        set init 3
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
       
    }
    
    runStep "Verify RAT Type before and after the Handover" {
     
        set j 1
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]     
        
        set rat "Virtual "
        set ratCode "(7)"
        ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]   
        
        set rat "EUTRAN "
        set ratCode "(6)"
        ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        set j 2
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]     
        
        set rat "Virtual "
        set ratCode "(7)"
        ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode                
        
    }
    
    runStep "Verify the Handover Stats" {
                
        ePDG:statsAfterHandover out $returnStats(statsCsSgw) count1 $originalStats2(count1) count2 $originalStats2(count2) count3 $originalStats2(count3) count4 $originalStats2(count4)
        ePDG:statsAfterHandover out $returnStats(statsMbaSgw) count1 $originalStats3(count1) count2 $originalStats3(count2) count3 $originalStats3(count3) count4 $originalStats3(count4)
        
        set out [dut exec "show zone default gateway statistics procedure-duration pgw PGW-1 create-session | notab | include count"]
        ePDG:statsAfterHandover out $out count1 $originalStats5(count1) count2 $originalStats5(count2) count3 $originalStats5(count3) count4 $originalStats5(count4)
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsAfter
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +1 ] && $toNon3gppHoStatsAfter == [ expr $toNon3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
    }
    
} {
    # Cleanup
    
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
        
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
    ue2 data set "apn_info \"APN:[tb _ dut.apn1]\""
    ue2 data set "pdnip_apn1 \"PDNIPADDRESS:v4 0\""
    ue2 data set "pdnip_apn2 \"PDNIPADDRESS:v4 0\""
	trans config
    trans init
        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
if { $i == 0 } {
	set id        ePDG:section3:S2B:C529860
} else {
	set id        ePDG:section3:S2B:C529861
}
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/27/2016
set pctComp   100
set summary   "This Test verifies that UE attach first via S5/s8 then handovers to s2b then handover back to S5/s8 - with IPv4/IPv6 data"
set descr     "
1.  Record the Stats before Handover and Disable the PCRF Interface
2.  Start the Packet Capture ; Bring up and Handover the sessions
3.  Find the GTP-C Tunnel endpoint IP addresses
4.  Verify S2b and S5/S8 Interface Type and Code from the Packet capture
5.  Verify RAT Type before and after the Handover
6.  Verify S2b and S5/S8 Interface Stats
7.  Verify the Handover Stats"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Record the Stats before Handover" {
    
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsBefore
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsBefore
        
        set out [dut exec "show zone default gateway statistics procedure-duration pgw PGW-1 create-session | notab | include count"]
        array set originalStats5 [ePDG:statsBeforeHandover $out]
                
    }
    
    runStep "Start the Packet Capture ; Bring up and Handover the sessions" {        
        
        trans init
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
       
        if { $i == 0 } {            
            array set returnStats [ePDG:v4Handover3gppToNon3gppTo3gpp]            
        } else {
            array set returnStats [ePDG:v6Handover3gppToNon3gppTo3gpp]            
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Find the GTP-C Tunnel endpoint IP addresses" {
        
        set out [dut exec "show running-config network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        set out [dut exec "show running-config network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address"]
        
        if { [regexp.an -lineanchor {^\s*ip-address\s+([0-9:a-z]+)$} $out - ip3] } {
            log.test "SGW Loopback ip-address: $ip3"
        } else {
            error.an "Failed to retrieve SGW Loopback ip-address"
        }           
        
    }
    
    runStep "Verify S2b and S5/S8 Interface Type and Code from the Packet capture" {
        
        set loop 1
        ePDG:verifyS5S8Interface $loop
        
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 3
        set init 2
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 3
        set init 2
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init        
        
        set loop 3
        ePDG:verifyS5S8Interface $loop
       
    }
    
    runStep "Verify RAT Type before and after the Handover" {
     
        set j 1
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]   
        
        set rat "EUTRAN "
        set ratCode "(6)"
        ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]     
        
        set rat "Virtual "
        set ratCode "(7)"
        ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode
        
        set j 2
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==[tb _ trans.enodeb.ipv6] and ipv6.dst==$ip3' | grep -e 'Create Session Request' | sed -n '$j p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]   
        
        set rat "EUTRAN "
        set ratCode "(6)"
        ePDG:verifyRatType rat $rat frameNumber $frameNumber ratCode $ratCode           
        
    }
    
    runStep "Verify the Handover Stats" {
        
        ePDG:statsAfterHandover out $returnStats(statsCsPgw) count1 $originalStats5(count1) count2 $originalStats5(count2) count3 $originalStats5(count3) count4 $originalStats5(count4)
        
        array set statsCsSgw [ePDG:statsBeforeHandover $returnStats(originalStats2)]
        array set statsMbaSgw [ePDG:statsBeforeHandover $returnStats(originalStats3)]
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] 3gpp-to-non-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*3gpp-to-non-3gpp-handover-success\s+([0-9]+)$} $out - toNon3gppHoStatsAfter
        
        set out [dut exec "show zone default gateway statistics cluster-level procedure pgw PGW-1 [tb _ dut.chassisNumber] non-3gpp-to-3gpp-handover-success"]
        regexp.an -lineanchor {^\s*non-3gpp-to-3gpp-handover-success\s+([0-9]+)$} $out - to3gppHoStatsAfter
        
        if { $toNon3gppHoStatsAfter == [ expr $toNon3gppHoStatsBefore +1 ] && $to3gppHoStatsAfter == [ expr $to3gppHoStatsBefore +1 ] } {
            log.test "Handover Stats Verified"            
        } else {
            error.an "Unable to verify Handover stats"
        }
        
        set out [dut exec "show zone default gateway statistics procedure-duration sgw SGW-1 create-session | notab | include count"]
        ePDG:statsAfterHandover out $out count1 $statsCsSgw(count1) count2 $statsCsSgw(count2) count3 $statsCsSgw(count3) count4 $statsCsSgw(count4)
        
        set out [dut exec "show zone default gateway statistics procedure-duration sgw SGW-1 modify-bearer-request | notab | include count"]             
        ePDG:statsAfterHandover out $out count1 $statsMbaSgw(count1) count2 $statsMbaSgw(count2) count3 $statsMbaSgw(count3) count4 $statsMbaSgw(count4)
        
    }
    
} {
    # Cleanup
    
    catch {trans terminateCall}
    ePDG:checkSessionState
    
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
        
    ue2 exec "/etc/init.d/networking restart"
    catch {ue2 exec "route add [tb _ os.ip] gw 22.[tb _ dut.chassisNumber].0.1"}
    
    ue2 data set "pdnipaddress \"PDNIPADDRESS:v4 0\""
    ue2 data set "handover_flag \"#HANDOVER_FLAG:TRUE\""
    ue2 data set "apn_info \"APN:[tb _ dut.apn1]\""
    ue2 data set "pdnip_apn1 \"PDNIPADDRESS:v4 0\""
    ue2 data set "pdnip_apn2 \"PDNIPADDRESS:v4 0\""
	trans config
    trans init
        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
set id        ePDG:section3:S2B:C212220:C212223:C775129
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   6/16/2016
set pctComp   100
set summary   "This Test verifies that UE attach with 2 PDNs (v4/v6) - 2 network initiated dedicated bearers with data on dedicated bearers "
set descr     "
1.  Start 2nd PCRF Server and Verify PCRF-2 server is listening
2.  Start 2nd PCRF Server and Verify PCRF-2 server is listening
3.  Bring v4 Sessions with 2 APNs and pass the Data
4.  Verify the Bearer Stats on MCC
5.  Bring v6 Sessions with 2 APNs and pass the Data
6.  Verify the Bearer Stats on MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Change Workflow Subscriber Analyzer Config" {

        dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG; no key key1"
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1"
        dut exec config "commit"        
        dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG key key1 epdg-name EPDG-1"        
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 apn-name apn.epdg-access-pi.net"
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW-2 priority 7 action data-profile DATA-PROFILE-2 control-profile CONTROL-PROFILE-PGW-2"
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW-2 key key1 apn-name apn2.epdg-access-pi.net"
        dut exec config "commit"
        
    }
    
    runStep "Start 2nd PCRF Server and Verify PCRF-2 server is listening" {
        
        pcrfsim2 init
        sleep 5
       
        set out [dut exec "show service-construct interface aaa-interface-group diameter peer-status"]

        if { [set status_ [cmd_out . values.PCRF-2.STATUS]] == "okay" } {
            log.test "PCRF-2 Server is connected to PGW; PCRF-2 STATUS is 'okay'"
        } else {
            error.an "PCRF-2 Server is not connected to PGW; Expected PCRF-2 STATUS to be 'okay' but got '$status_'"
        }
            
    }

    runStep "Bring v4 Sessions with 2 APNs and pass the Data" {

        array set ipsec2 [ePDG:start_ipsec_sessionv4_2apns]
        ePDG:ue_ping_os $ipsec2(ueIp4_1)
        ePDG:ue_ping_os2 $ipsec2(ueIp4_1)
        ePDG:ue_tcp_os $ipsec2(ueIp4_1)
        ePDG:ue_ping_os $ipsec2(ueIp4_2)
        ePDG:ue_ping_os2 $ipsec2(ueIp4_2)
        ePDG:ue_tcp_os $ipsec2(ueIp4_2)
    
    }
    
    runStep "Verify the Bearer Stats on MCC" {
        
        for {set i 0} {$i < 2} {incr i} {
        
            set index $i
            set c1 5
            set c2 5
            set c3 14
            set c4 12
            set c5 5
            set c6 5
            ePDG:verifyBearerStats index $index c1 $c1 c2 $c2 c3 $c3 c4 $c4 c5 $c5 c6 $c6
            
        }
        
    }
    
    runStep "Bring v6 Sessions with 2 APNs and pass the Data" {
        
        array set ipsec2 [ePDG:start_ipsec_sessionv6_2apns]
        ePDG:ue_ping6_os $ipsec2(ueIp6_1)
        ePDG:ue_ping6_os2 $ipsec2(ueIp6_1)
        ePDG:ue_tcp6_os $ipsec2(ueIp6_1)
        ePDG:ue_ping6_os $ipsec2(ueIp6_2)
        ePDG:ue_ping6_os2 $ipsec2(ueIp6_2)
        ePDG:ue_tcp6_os $ipsec2(ueIp6_2)
    
    }
    
    runStep "Verify the Bearer Stats on MCC" {
        
        for {set i 0} {$i < 2} {incr i} {
        
            set index $i
            set c1 5
            set c2 5
            set c3 14
            set c4 12
            set c5 5
            set c6 5
            ePDG:verifyBearerStats index $index c1 $c1 c2 $c2 c3 $c3 c4 $c4 c5 $c5 c6 $c6
            
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "no workflow subscriber-analyzer SUB-ANA-PGW-2"
    dut exec config "commit"        
    dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG; no key key1"
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1"
    dut exec config "commit"        
    dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG key key1 apn-name apn.epdg-access-pi.net"        
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1"        
    dut exec config "commit"    
    pcrfsim2 stop
    sleep 5
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section3:S2B:C212255
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/27/2016
set pctComp   100
set summary   "This test verifies that PCRF server initiates the s2b session termination"
set descr     "
1.  Clear any previous sessions and Stop the PCRF Server
2.  Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the PCRF initiated session termination timer as 20 sec
3.  Start the Packetcapture & Bring up the session
4.  Decode TCP Packets as DIAMETER and Import Packet info
5.  Verify the Diameter AVP for RA Request
6.  Verify the Diameter Result in RA Answer
7.  Verify that the PGW sends CCR to PCRF with Termination Request
8.  Verify the Diameter Result in CC Answer
9.  Verify S2b Interface Type and Code from the Packet capture
10. Verify that ePDG sends Delete Bearer Response to PGW with Request accepted
11. Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear any previous sessions and Stop the PCRF Server" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        pcrfsim stop
        #pcrfsim2 stop
        sleep 5
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] pcrf-initiated-close-attempts"
        set pcrfInitiatedCloseBefore [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.PCRFINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type GX PCRF-1 pcrf-server.carrier.net"
        
        set num_ccr_initial_success [cmd_out . values.num-ccr-initial-success]
        set num_cca_attempt [cmd_out . values.num-cca-initial-rcvd-first-attempt]
        set num_rar [cmd_out . values.number-of-rar-received]
        set num_raa [cmd_out . values.number-of-raa-success]
        set num_ccr_terminate [cmd_out . values.num-ccr-terminate-success]
        
    }
    
    runStep "Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the PCRF initiated session termination timer as 30 sec" {
       
        pcrfsim data set "SessCloseNumTimeSlots 3"
        pcrfsim init
        sleep 5
                
    }
    
    runStep "Start the Packetcapture & Bring up the session" {
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name S2B-EPDG-5-1"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        sleep 35
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
                
        import_tshark_file
        
    }
    
     runStep "Decode TCP Packets as DIAMETER and Import Packet info" {
        
        set packet_info [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter'"]
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip PCRF-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_pcrf_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and ip.src==[tb _ pcrfsim.serverIp] and ip.dst==$pgw_pcrf_lbv4' | grep -e 'Re-Auth Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }
    
     runStep "Verify the Diameter AVP for RA Request" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.avp.code\" showname=\"AVP Code: 1045 Session-Release-Cause\"' | sed -n '1p'"]
        set rarInfo [ePDG:store_last_line $out1]
        
        if { [regexp.an "value=\"00000415\"" $rarInfo] && [regexp.an "show=\"1045\"" $rarInfo] } {
            log.test "Diameter AVP for RAR verified"
        } else {
            error.an "Failed to verify Diameter AVP for RAR"
        }   
        
    }
    
    runStep "Verify the Diameter Result in RA Answer" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and ip.src==$pgw_pcrf_lbv4 and ip.dst==[tb _ pcrfsim.serverIp]' | grep -e 'Re-Auth Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
                        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - $diameter_result ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify that the PGW sends CCR to PCRF with Termination Request" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and ip.src==$pgw_pcrf_lbv4 and ip.dst==[tb _ pcrfsim.serverIp]' | grep -e 'Credit-Control Request' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.CC-Request-Type\" showname=\"CC-Request-Type: ' | sed -n '1p'"]
        set ccrInfo [ePDG:store_last_line $out1]
        
        regexp.an {\"CC-Request-Type:\s([A-Z_]+)} $ccrInfo - ccrCause
        
        if { [regexp.an "value=\"00000003\"" $ccrInfo] && [regexp.an "show=\"3\"" $ccrInfo] &&  [string match $ccrCause "TERMINATION_REQUEST"] == 1 } {
            log.test "Found Credit Control Request with Termination Request from PGW"
        } else {
            error.an "Unable to find Credit Control Request with Termination Request from PGW"
        }   
        
    }
    
    runStep "Verify the Diameter Result in CC Answer" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and ip.src==[tb _ pcrfsim.serverIp] and ip.dst==$pgw_pcrf_lbv4' | grep -e 'Credit-Control Answer' | sed -n '2p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
                        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ pcrfsim.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - $diameter_result ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify S2b Interface Type and Code from the Packet capture" {
                
        catch { dut exec shell "scp /var/log/eventlog/S2B-EPDG-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*" }
                
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 2
        set init 1
       ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init        
        
    }
    
    runStep "Verify that ePDG sends Delete Bearer Response to PGW with Request accepted" {
                
        set out1 [tshark exec "tshark -r /tmp/umakant -Y gtpv2 | grep -e 'Delete Bearer Response' | sed -n '1p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and frame.number==$frameNumber' -T pdml | grep -e ' <field name=\"gtpv2.cause\" showname=\"Cause: ' | sed -n '1p'"]
        set terminationCause [ePDG:store_last_line $out1]
        
        regexp.an {\"Cause:\s([A-Z_a-z]+)\s([A-Z_a-z]+)} $terminationCause - termination Result
        
        if { [regexp.an "value=\"10\"" $terminationCause] && [regexp.an "show=\"16\"" $terminationCause] &&  [string match "$termination $Result" "Request accepted"] == 1 } {
            log.test "Found Delete Bearer Response from ePDG"
        } else {
            error.an "Unable to find Delete Bearer Response"
        }   
        
    }
    
    runStep "Verify the Stats" {
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] pcrf-initiated-close-attempts"
        set pcrfInitiatedCloseAfter [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.PCRFINITIATEDCLOSEATTEMPTS]
    
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type GX PCRF-1 pcrf-server.carrier.net"
        
        if { $pcrfInitiatedCloseAfter == [expr $pcrfInitiatedCloseBefore +1] && [cmd_out . values.num-ccr-initial-success] == [ expr $num_ccr_initial_success +1 ] && [cmd_out . values.num-cca-initial-rcvd-first-attempt] == [ expr $num_cca_attempt +1 ] && [cmd_out . values.number-of-rar-received] == [ expr $num_rar +1 ] && [cmd_out . values.number-of-raa-success] == [ expr $num_raa +1 ] && [cmd_out . values.num-ccr-terminate-success] == [ expr $num_ccr_terminate +1 ] } {
            log.test "Stats Verified"
        } else {
            error.an "Unable to verify Stats"
        }
        
    }    
        
} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    catch { dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*" }    
    pcrfsim stop    
    pcrfsim data set "SessCloseNumTimeSlots 0"
    #pcrfsim2 init
    pcrfsim init
    sleep 5
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section3:S2B:C212256
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/27/2016
set pctComp   100
set summary   "This test verifies that AAA initates the S2b session termination"
set descr     "
1.  Clear any previous sessions and Stop the AAA Server
2.  Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the AAA initiated session termination timer as 20 sec
3.  Change the AUTH_STATE to 1 \( NO_STATE_MAINTAINED \) in s6bserver python script
4.  Start the Packetcapture & Bring up the session
5.  Decode TCP Packets as DIAMETER and Import Packet info ; Check if There is NO STR sent
6.  Verify the Authorization State in AA Answer to be \"NO_STATE_MAINTAINED\"
7.  Verify the Diameter Result in ASR
8.  Verify S2b Interface Type and Code from the Packet capture
9.  Verify that ePDG sends Delete Bearer Response to PGW with Request accepted
10.  Verify the Stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Clear any previous sessions and Stop the AAA Server" {
        
        dut exec "subscriber clear-local"
        ue exec "ipsec restart"
        
        s6b stop
        
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_before [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        set num_aar_initial_success [cmd_out . values.num-aar-initial-success]
        set num_aar_attempt [cmd_out . values.num-aaa-initial-rcvd-first-attempt]
        set num_asr_request [cmd_out . values.num-asr-request-received]
        
    }
    
    runStep "Change the 3rd digit after Data Record corresponding to \[SessCloseNumTimeSlots\] in imsidb.txt to 2 to set the AAA initiated session termination timer as 20 sec" {
       
        s6b data set "SessCloseNumTimeSlots 2"
                
    }
    
    runStep "Change the AUTH_STATE to 1 \( NO_STATE_MAINTAINED \) in s6bserver python script" {
        
        s6b configure -server s6bserver2
        s6b init
        sleep 5
                        
    }
    
    runStep "Start the Packetcapture & Bring up the session" {
        
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 10000 duration 600 file-name umakant"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name S2B-EPDG-5-1"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        sleep 25
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
     runStep "Decode TCP Packets as DIAMETER and Import Packet info ; Check if There is NO STR sent" {
        
        set packet_info [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter'"]
        
        if { ![regexp.an "Session-TerminationRequest" $packet_info] } {
            log.test "NO STR Found"
        } else {
            error.an "STR Found ; Check the python script and try again"
        }
        
        set ip_info [dut exec "show running-config network-context GI-QA loopback-ip S6b_Dia_v4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_s6b_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==[tb _ s6b.serverIp] and ip.dst==$pgw_s6b_lbv4' | grep -e 'AA Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }
    
     runStep "Verify the Authorization State in AA Answer to be \"NO_STATE_MAINTAINED\"" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Auth-Session-State\" showname=\"Auth-Session-State:' | sed -n '2p'"]
        set auth_state_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Auth-Session-State:\s([A-Z_]+)} $auth_state_info - auth_state
        
        if { [string match $auth_state "NO_STATE_MAINTAINED"] == 1 } {
            log.test "Authorization State Verified"
        } else {
            error.an "Authorization State does not match ; Authorization State is $auth_state ; Expected is NO_STATE_MAINTAINED"
        }
        
    }
    
    runStep "Verify the Diameter Result in ASR" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and ip.src==$pgw_s6b_lbv4 and ip.dst==[tb _ s6b.serverIp]' | grep -e 'Abort-Session Answer' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
                        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ s6b.serverPort],diameter -Y 'diameter and frame.number==$frame_number' -T pdml | grep -e '<field name=\"diameter.Result-Code\" showname=\"Result-Code: ' | sed -n '1p'"]
        set diameter_result_info [ePDG:store_last_line $out1]
        
        regexp.an {\"Result-Code:\s([A-Z_]+)} $diameter_result_info - diameter_result
        
        if { [string match $diameter_result "DIAMETER_SUCCESS"] == 1 } {
            log.test "Diameter Transaction Successful"
        } else {
            error.an "Diameter Transaction Unsuccessful, Result Code: - $diameter_result ; Expected Result is DIAMETER_SUCCESS"
        }

    }
    
    runStep "Verify S2b Interface Type and Code from the Packet capture" {
                
        catch { dut exec shell "scp /var/log/eventlog/S2B-EPDG-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*" }
                
        set gateway "ePDG"
        set packet "Create Session Request"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init
        
        set gateway "PGW"
        set packet "Create Session Response"
        set loop 2
        set init 1
        ePDG:verifyS2bInterface gateway $gateway packet $packet loop $loop init $init        
        
    }
    
    runStep "Verify that ePDG sends Delete Bearer Response to PGW with Request accepted" {
                
        set out1 [tshark exec "tshark -r /tmp/umakant -Y gtpv2 | grep -e 'Delete Bearer Response' | sed -n '1p' | awk  '{print \$1}'"]
        set frameNumber [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and frame.number==$frameNumber' -T pdml | grep -e ' <field name=\"gtpv2.cause\" showname=\"Cause: ' | sed -n '1p'"]
        set terminationCause [ePDG:store_last_line $out1]
        
        regexp.an {\"Cause:\s([A-Z_a-z]+)\s([A-Z_a-z]+)} $terminationCause - termination Result
        
        if { [regexp.an "value=\"10\"" $terminationCause] && [regexp.an "show=\"16\"" $terminationCause] &&  [string match "$termination $Result" "Request accepted"] == 1 } {
            log.test "Found Delete Bearer Response from ePDG"
        } else {
            error.an "Unable to find Delete Bearer Response"
        }   
        
    }
    
    runStep "Verify the Stats" {
    
        dut exec "show zone default gateway statistics node-level call-performance apn [tb _ dut.apn1] s6b-initiated-close-attempts"
        set s6b_close_attempts_after [cmd_out . values.[tb _ dut.apn1]:[tb _ dut.chassisNumber]:1.S6BINITIATEDCLOSEATTEMPTS]
        
        dut exec "show service-construct interface aaa-interface-group diameter statistics cluster-level peer interface-type S6B S6BDiameter s6bPeer1"
        
        if { $s6b_close_attempts_after == [expr $s6b_close_attempts_before +1] && [cmd_out . values.num-aar-initial-success] == [ expr $num_aar_initial_success +1 ] && [cmd_out . values.num-aaa-initial-rcvd-first-attempt] == [ expr $num_aar_attempt +1 ] && [cmd_out . values.num-asr-request-received] == [ expr $num_asr_request +1 ] } {
            log.test "Stats Verified"
        } else {
            error.an "Unable to verify Stats"
        }
       
    }    
        
} {
    # Cleanup
    s6b stop
    s6b configure -server [tb _ s6b.server]
    
    s6b data set "SessCloseNumTimeSlots 0"
    
    s6b init
    sleep 5
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section3:S2B:C212266
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/28/2016
set pctComp   100
set summary   "This Test verifies that local CDRs are populated as expected for S2b ssession"
set descr     "
1.  Bring up the session
2.  Decode the .CSV file
3.  Verify the Record Type for ePDG
4.  Verify the details in CDR with those on MCC
5.  Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs"
runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the session" {
        
        if { [dut . configurator testCmd "service-construct data-record-template epdg charging-local interim epdg-interim duration presentFlag conditional"] == 1 } {
            dut exec config "service-construct data-record-template epdg charging-local interim epdg-interim duration presentFlag conditional"
            dut exec config "commit"   
            log.test "Duration field set to Conditional"  
        } else {
            error.an "Duration Field is not supported on This Build" "" SKIP_TEST            
        }
        
        #dut exec config "workflow subscriber-analyzer SUB-ANA-EPDG priority 6"
        #dut exec config "commit"

        ue exec "ipsec restart"
        catch {dut exec shell "cd /var/log/datarecord/; rm *"}
        
        array set ipsec [ePDG:start_ipsec_session]        
        sleep 150
        
    }
    
    runStep "Decode the .CSV file and Filter out the Intermediate Record Type" {

        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/cdrProc7.2.0B.pl /var/log/datarecord/" -password [dut . filePassword]
        
        set count [dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR* | wc -l"]        
        dut exec shell "cd; ls /var/log/datarecord/ePDG-CDR*"
        dut exec shell "cd /var/log/datarecord/; perl cdrProc7.2.0B.pl [lindex [cmd_out . full] [expr $count - 1]] > decodedCdrInfo.txt"
        dut exec shell "cd; cat /var/log/datarecord/decodedCdrInfo.txt"
        #set filteredResult [dut exec shell "awk '/(Intermediate)/, /Served PDP Address/' decodedCdrInfo.txt | awk '1;/Served PDP Address/{exit}'"]
        set filteredResult [dut exec shell "awk '/(Intermediate)/, /IKE Local Port/' /var/log/datarecord/decodedCdrInfo.txt | awk '1;/IKE Local Port/{exit}'"]
        
    }
    
    runStep "Verify the Record Type for ePDG" {
        
        regexp.an {\s*Accounting Record Type\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)\s*Record Type\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)\s+([a-z\(\)A-Z]+)} $filteredResult - r1 r2 recordLevel r4 r5 recordType
        
        if { [string match $recordLevel "(Intermediate)"] == 1 && [string match $recordType "(ePDG)"] == 1} {
            log.test "ePDG Intermediate Record Found"
        } else {
            error.an "Unable to find ePDG Intermediate Record"
        }      
        
    }
    
    runStep "Verify the details in CDR with those on MCC" {
        
        set out [dut exec "show running-config service-construct interface offline-charging ePDG-INTF epdg interim-update-interval | include interim-update-interval"]
        if { [regexp.an -lineanchor {^\s*epdg interim-update-interval\s+([0-9]+)$} $out - durationMcc] } {
            log.test "Found Duration value confiured on MCC: $durationMcc"
        } else {
            error.an "Unable to find the Duration value on MCC"
        }
        
        regexp.an -all {\s*Served IMSI\s+\[INT:\s+([0-9]+)\]\s+([-0-9]+)} $filteredResult - r1 imsi
        puts "Served IMSI: $imsi"
        regexp.an -all {\s*Served MNNAI\s+\[INT:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 imsi_nai
        puts "Served MNNAI: $imsi_nai"
        regexp.an -all {\s*ePDG FQDN\s+\[INT:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 fqdn
        puts "ePDG FQDN: $fqdn"
        regexp.an -all {\s*APN ID\s+\[INT:\s+([0-9]+)\]\s+([-0-9a-zA-Z@.:_]+)} $filteredResult - r1 apn_id
        puts "APN ID: $apn_id"
        regexp.an -all {\s*Duration\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)\s+seconds\s+\(0 days 0 hours 2 mins 0 secs\)} $filteredResult - r1 time
        puts "DURATION: $time"
        
        if { [string match [tb _ ue.IMSI] $imsi] == 1 && [string match [tb _ ue.imsi_nai] $imsi_nai] == 1 && [string match [tb _ dut.fqdn] $fqdn] == 1 && [string match [tb _ dut.apn1] $apn_id] == 1 && [string match $durationMcc $time] == 1} {
            log.test "CDRs are populated as expected"
        } else {
            error.an "Details in CDR do not match with those configured on MCC"
        }
        
    }
    
    runStep "Extract and Verify IKE IP and Port Info from UE as well as from Decoded CDRs" {
        
        regexp.an -all {\s*IKE Remote IP Address\s+\[INT:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip1
        regexp.an -all {\s*IKE Remote Port\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port1
        regexp.an -all {\s*IKE Local IP Address\s+\[INT:\s+([0-9]+)\]\s+([0-9.a-z:]+)} $filteredResult - r1 ip2
        regexp.an -all {\s*IKE Local Port\s+\[INT:\s+([0-9]+)\]\s+([0-9]+)} $filteredResult - r1 port2
        puts "Info Extracted from CDR - IKE Remote IP Address: $ip1 ; IKE Remote Port: $port1 ; IKE Local IP Address: $ip2 ; IKE Local Port: $port2"
        
        regexp.an -all {\s*sending packet: from\s+([0-9.]+)\[([0-9]+)\]\s+to\s+([0-9.]+)\[([0-9]+)\]} $ipsec(ipsecinfo) - ike_ip1 ike_port1 ike_ip2 ike_port2
        puts "Info Extracted from UE - IKE Remote IP Address: $ike_ip1 ; IKE Remote Port: $ike_port1 ; IKE Local IP Address: $ike_ip2 ; IKE Local Port: $ike_port2"        
        
        if { [string match $ip1 $ike_ip1] == 1 && [string match $port1 $ike_port1] == 1 && [string match $ip2 $ike_ip2] == 1 && [string match $port2 $ike_port2] == 1} {
            log.test "IKE IP and Port Info matched"
        } else {
            error.an "IKE IP and Port Info do not match"
        }      
        
    }
    
} {
    # Cleanup
    catch { dut exec shell "rm /var/log/datarecord/decodedCdrInfo*" }
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section3:S2B:C226676:C226677
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   10/28/2016
set pctComp   100
set summary   "This Test verifies that the TEID in pdn-session match with the debug stats"
set descr     "
1.  Find the Task name for the current PGW Session ID
2.  Find the Task name for the current PGW Session ID
3.  Find the TEIDs from Degug stats
4.  Check if TEID in pdn-session matches with the one in the debug stats"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the non-3gpp session" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
    }
    
    runStep "Find the Task name for the current PGW Session ID" {
    
        dut exec "show subscriber summary gateway-type pgw"
        
        set serviceName [cmd_out . values.[cmd_out . key-values].SERVICENAME]   
       
        dut exec "show cluster [tb _ dut.chassisNumber] node 1 processes cpu1 $serviceName*"
        
        set processes [cmd_out . key-values]
        
        foreach kv $processes {
            set act [cmd_out . values.$kv.HASTATE]
            if {$act == "active"} {
                set taskName [cmd_out . values.$kv.TASKNAME]
            }
        }
    
    }
    
    runStep "Find the TEIDs from Degug stats" {
        
        set debugInfo [dut exec "cluster [tb _ dut.chassisNumber] node 1 processes cpu1 $taskName debug pdn-session $ipsec(pgw_sessionid)"]    
        
        regexp.an {\s*PdnConnection \[0\] Apn: apn.epdg-access-pi.net Details:\s+Pdn Session Id\s+:\s+([0-9]+)} $debugInfo - id1
        
        regexp.an {\s*Ingress Ctrl Outgoing Information\s+Interface Type\s+:\s+30\s+Network Context\s+:\s+([0-9]+)\s+TEID\s+:\s+([0-9]+)} $debugInfo - temp id2
        
        regexp.an {\s*Ingress Ctrl Incoming Information\s+Interface Type\s+:\s+32\s+Network Context\s+:\s+([0-9]+)\s+TEID\s+:\s+([0-9]+)} $debugInfo - temp id3
   
    }                            
    
    runStep "Check if TEID in pdn-session matches with the one in the debug stats" {        
        
        set out [dut exec "show subscriber pdn-session $ipsec(pgw_sessionid)"]
        
        regexp.an {\s*access-in-control-teid-value\s+([0-9]+)} $out - inTeid
        
        regexp.an {\s*access-out-control-teid-value\s+([0-9]+)} $out - outTeid
        
        if { [string match $inTeid $id1] == 1 && [string match $outTeid $id2] == 1 && [string match $inTeid $id3] == 1 } {
            log.test "TEID in pdn-session matches with the one in the debug stats"
        } else {
            error.an "TEID in pdn-session does not match with the one in the debug stats"
        }
                
    }
            
} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C96678
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/03/2016
set pctComp   100
set summary   "This test verifies the Session with no IDr (APN) from UE, ePDG is not mapped to a default APN "
set descr     "
1.  Remove Default Mapped APN, Comment APN in ipsec.conf and bring up the session
2.  Bring up the session and check if it fails"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Remove Default Mapped APN and Change the parameters in ipsec.conf file" {

        dut exec config "no zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 mapped-apn-name"
        dut exec config "commit"
        
        ue exec "sed -i 's/#*rightid=apn2.epdg-access-pi.net/#rightid=apn2.epdg-access-pi.net/g' /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check if it fails" {
        
        catch [ue exec "ipsec restart"]        
        ue closeCli
        ue initCli -4 true
        
        catch {ue exec "ipsec up epdg-apn2" -timeout 200} result
        #[regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+initiating IKE_SA epdg-apn2\[([0-9]+)\] to ([0-9.]+)\s+establishing connection 'epdg-apn2' failed} $result]            
        if { [regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+establishing connection 'epdg-apn2' failed} $result] == 1 ||
            [regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+initiating IKE_SA epdg-apn2\[([0-9]+)\] to ([0-9.:a-zA-Z]+)\s+generating IKE_SA_INIT request ([0-9]+) \[([A-Za-z_\(\)0-9\s]+)\]\s+establishing connection 'epdg-apn2' failed} $result] ==1 ||
            [regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+initiating IKE_SA epdg-apn2\[([0-9]+)\] to ([0-9.:a-zA-Z]+)\s+establishing connection 'epdg-apn2' failed} $result] ==1 ||
            [regexp.an {\s*received EAP_FAILURE, EAP authentication failed\s+generating INFORMATIONAL request ([0-9]+) \[ N\(AUTH_FAILED\) \]\s+sending packet: from ([0-9.a-z:\[\]]+) to ([0-9.a-z:\[\]]+) \(([0-9]+) bytes\)\s+establishing connection 'epdg-apn2' failed} $result] == 1 } {
            log.test "UE reports: connection 'epdg-apn2' Failed"
        } else {
            error.an "Logs do not have IPSec Fail message. Expacted is : \"establishing connection 'epdg-apn2' failed\""
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 mapped-apn-name [tb _ dut.apn1]"
    dut exec config "commit"    
    catch {ue exec "cp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "ipsec restart"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C96679:C80134
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/03/2016
set pctComp   100
set summary   "This test verifies the Session with IDr (APN) from UE but ePDG is mapped to a default APN which different from UE IDr "
set descr     "
1.  Bring up the session & Check the Data Path
2.  Verify the session is attached with Corresponding (Non-Default APN)"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Bring up the session and check the Data Path" {
        
        ue exec "ipsec restart"
        after 2000
        ue closeCli
        ue initCli -4 true
        set out1 [ue exec "ipsec up epdg-apn2" -exitCode 0]

        if { [regexp.an "connection 'epdg-apn2' established successfully" $out1] } {
            log.test "UE reports: connection 'epdg-apn2' established successfully"
        } else {
            error.an "Failed to establish 'epdg-apn2' connection"
        }

        if { [regexp.an {installing new virtual IP ([0-9.]+)\sinstalling new virtual IP ([0-9:a-z]+)} $out1 - ueIpv4 ueIpv6] } {
            log.test "Found new virtual IPv4 and IPv6: $ueIpv4 $ueIpv6"
        } else {
            error.an "Failed to retrieve new virtual IPs"
        }

        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { ![string is integer -strict [set pgwid [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one pgw session"
        } else {
            log.test "Found pgw session with id: $pgwid"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*ue-v4-ip-address\s+([0-9.]+)$} $out - ueIp4] } {
            log.test "Found ue-v4-ip-address: $ueIp4"
        } else {
            error.an "Failed to retrieve ue-v4-ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*ue-v6-ip-address\s+([0-9:a-z]+)$} $out - ueIp6] } {
            log.test "Found ue-v6-ip-address: $ueIp6"
        } else {
            error.an "Failed to retrieve ue-v6-ip-address"
        }

        if { $ueIpv4 == $ueIp4 && $ueIpv6 == $ueIp6 } {
            log.test "UE IP addresses as reported by UE and MCC match"
        } else {
            error "UE IP addresses as reported by UE ($ueIpv4 & $ueIpv6) and MCC ($ueIp4 & $ueIp6) do not match"
        }

        set out [ue exec "ip -o addr show up primary scope global"]

        if { [regexp "$ueIp4" $out] && [regexp "$ueIp6" $out]  } {
            log.test "IP address reported by UE"
        } else {
            error.an "UE does not report the new IP ($ueIp4 and $ueIp6) as active"
        }
                
        ePDG:ue_ping_os $ueIp4
        ePDG:ue_ping_os2 $ueIp4
        ePDG:ue_tcp_os $ueIp4
        ePDG:ue_ping6_os $ueIp6
        ePDG:ue_ping6_os2 $ueIp6
        ePDG:ue_tcp6_os $ueIp6
         
    }
    
    runStep "Verify the session is attached with Corresponding (Non-Default APN)" {
    
        set out [dut exec "show subscriber pdn-session $pgwid"]
        
        if { [regexp.an -lineanchor {^\s*apn-name\s+([-0-9.a-zA-Z_]+)$} $out - apnName] && [string match $apnName [tb _ dut.apn2]] ==1 } {
            log.test "Found the session with APN: $apnName"
        } else {
            error.an "Unable to find the session with APN: $apnName"
        }
    
    }
    
} {
    # Cleanup    
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C768090
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/03/2016
set pctComp   100
set summary   "This test verifies that UE requests dual stack and other optional IEs but PGW sends only few IEs"
set descr     "
1.  Change the parameters in ipsec.conf file
2.  Bring up the session and check if it fails
3.  Check if UE receives 1 v4 and 1 v6 DNS IP Addresses"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the parameters in ipsec.conf file" {
        
        dut exec config "no zone default gateway apn apn.epdg-access-pi.net dns-server-configuration primary-ipv4-address"
        dut exec config "commit"
        dut exec config "no zone default gateway apn apn.epdg-access-pi.net dns-server-configuration primary-ipv6-address"
        dut exec config "commit"
        dut exec config "no zone default gateway apn apn.epdg-access-pi.net pcscf-table"
        dut exec config "commit"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check if UE receives 1 v4 and 1 v6 DNS IP Addresses" {
        
        if { [regexp.an {\s*installing DNS server ([0-9.]+) via resolvconf\s+installing DNS server ([0-9a-z:A-Z]+) via resolvconf\s+installing new virtual IP ([0-9.]+)\s+installing new virtual IP ([0-9a-z:A-Z]+)} $ipsec(ipsecinfo) - uev4dnsIp1 uev6dnsIp1 ueip4 ueip6] } {
            log.test "Found DNS IPv4 and IPv6 addresses on UE: $uev4dnsIp1 $uev6dnsIp1"
        } else {
            error.an "Failed to retrieve DNS IPs"
        }
		
    }
    
    runStep "Find the DNS IP addresses configured on MCC" {
		
        set out [dut exec "show running-config zone default gateway apn dns-resolution-for-pgw-selection true"]
              
        if { [regexp.an -all -lineanchor {dns-server-configuration secondary-ipv4-address ([0-9.]+)} $out - dnssecIpv4] } {
            log.test "Found 2nd DNS IPv4 Address: $dnssecIpv4"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
        if { [regexp.an -all -lineanchor {dns-server-configuration secondary-ipv6-address ([0-9:a-z]+)} $out - dnssecIpv6] } {
            log.test "Found 2nd DNS IPv6 Address: $dnssecIpv6"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
    }
    
    runStep "Verify the DNS and PDN IP address" {
        
        if { [string match $uev4dnsIp1 $dnssecIpv4] == 1 && [string match $uev6dnsIp1 $dnssecIpv6] == 1 && [string match $ueip4 $ipsec(ueIp4)] == 1 && [string match $ueip6 $ipsec(ueIp6)] == 1} {
            log.test "DNS and PDN IP address Verified"
        } else {
            error.an "DNS and PDN IP addresses do not match"
        }
		
    }
    
} {
    # Cleanup
    dut exec config "zone default gateway apn apn.epdg-access-pi.net dns-server-configuration primary-ipv4-address 8.8.8.8"
    dut exec config "zone default gateway apn apn.epdg-access-pi.net dns-server-configuration primary-ipv6-address 2001:4860:4860::8888"
    dut exec config "zone default gateway apn apn.epdg-access-pi.net pcscf-table P-CSCF-TABLE-1"
    dut exec config "commit"
    
    catch {ue exec "cp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C100190
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/7/2016
set pctComp   100
set summary   "Test verifies that UE requests APN1 with IPv6 address but HSS sends PDN type as IPv4 "
set descr     "Change PDN type flag to '0' to make it IPv4 only session"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change PDN type flag to '0' to make it IPv4 only session" {
        
        swm init
        swm stop
        sleep 5
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE," str2 "pdntype = AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE, 0, ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ pdntype, serviceselection \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        catch {ue exec "ipsec up epdgv6" -timeout 200} result
        #[regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+initiating IKE_SA epdgv6\[([0-9]+)\] to ([0-9.]+)\s+establishing connection 'epdgv6' failed} $result]            
        if { [regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+establishing connection 'epdgv6' failed} $result] == 1 ||
            [regexp.an {\s*received EAP_FAILURE, EAP authentication failed\s+generating INFORMATIONAL request ([0-9]+) \[ N\(AUTH_FAILED\) \]\s+sending packet: from ([0-9.\[\]]+) to ([0-9.\[\]]+) \(([0-9]+) bytes\)\s+establishing connection 'epdgv6' failed} $result] == 1 ||
            [regexp.an {\s*giving up after 5 retransmits\s+peer not responding, trying again \(2/3\)\s+initiating IKE_SA epdgv6\[([0-9]+)\] to ([0-9.:a-zA-Z]+)\s+establishing connection 'epdgv6' failed} $result] ==1 } {
            log.test "UE reports: connection 'epdgv6' Failed"
        } else {
            error.an "Logs do not have IPSec Fail message. Expacted is : \"establishing connection 'epdg6' failed\""
        }
           
    }
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C100191
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/7/2016
set pctComp   100
set summary   "Test verifies that UE requests APN1 with IPv6 address but HSS sends PDN type as IPv4Ipv6"
set descr     "
1.  Change PDN type flag to '2' to make it IPv4Ipv6 session
2.  Check if UE receives V6 Attributes
3.  Find the DNS IP addresses configured on MCC
4.  Find the P-CSCF IP addresses configured on MCC
5.  Verify the DNS, P-CSCF and PDN IP address"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change PDN type flag to '2' to make it IPv4Ipv6 session" {
        
        swm init
        swm stop
        sleep 5
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE," str2 "pdntype = AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE, 2, ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ pdntype, serviceselection \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
        array set ipsec [ePDG:start_ipsecv6_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
		ePDG:ue_tcp6_os $ipsec(ueIp6)
        
    }
    
    runStep "Check if UE receives V6 Attributes" {
        
        if { [regexp.an {\s*installing DNS server ([0-9a-z:A-Z]+) via resolvconf\s+installing DNS server ([0-9a-z:A-Z]+) via resolvconf\s+received P-CSCF server IP ([0-9:a-z]+)\s+received P-CSCF server IP ([0-9:a-z]+)\s+installing new virtual IP ([0-9a-z:A-Z]+)} $ipsec(ipsecinfo) - uev6dnsIp1 uev6dnsIp2 uev6pcscfIp1 uev6pcscfIp2 ueip6] } {
            log.test "Found DNS, P-CSCF IPv6 addresses on UE: $uev6dnsIp1 $uev6dnsIp2 $uev6pcscfIp1 $uev6pcscfIp2"
        } else {
            error.an "Failed to retrieve DNS and P-CSCF IPs"
        }
		
    }
    
    runStep "Find the DNS IP addresses configured on MCC" {
		
        set out [dut exec "show running-config zone default gateway apn dns-resolution-for-pgw-selection true"]
              
        if { [regexp.an -all -lineanchor {dns-server-configuration primary-ipv6-address ([0-9:a-z]+)} $out - dnspriIpv6] } {
            log.test "Found 1st DNS IPv6 Address: $dnspriIpv6"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
        if { [regexp.an -all -lineanchor {dns-server-configuration secondary-ipv6-address ([0-9:a-z]+)} $out - dnssecIpv6] } {
            log.test "Found 2nd DNS IPv6 Address: $dnssecIpv6"
        } else {
            error.an "Failed to retrieve DNS IP Address"
        }
        
    }
    
    runStep "Find the P-CSCF IP addresses configured on MCC" {
		
        set out [dut exec "show running-config zone default gateway pcscf-table P-CSCF-TABLE-1 ip-v6-list primary-ipv6-address"]
              
        if { [regexp.an {primary-ipv6-address ([0-9:a-z]+)} $out - pcscfpriIpv6] } {
            log.test "Found 1st P-CSCF IPv6 Address: $dnspriIpv6"
        } else {
            error.an "Failed to retrieve P-CSCF IP Address"
        }
        
        set out [dut exec "show running-config zone default gateway pcscf-table P-CSCF-TABLE-1 ip-v6-list secondary-ipv6-address"]
        
        if { [regexp.an {secondary-ipv6-address ([0-9:a-z]+)} $out - pcscfsecIpv6] } {
            log.test "Found 2nd P-CSCF IPv6 Address: $dnssecIpv6"
        } else {
            error.an "Failed to retrieve P-CSCF IP Address"
        }
        
    }
    
    runStep "Verify the DNS, P-CSCF and PDN IP address" {
        
        if { [string match $uev6dnsIp1 $dnspriIpv6] == 1 && [string match $uev6dnsIp2 $dnssecIpv6] == 1 && [string match $uev6pcscfIp1 $pcscfpriIpv6] == 1 && [string match $uev6pcscfIp2 $pcscfsecIpv6] == 1 && [string match $ueip6 $ipsec(ueIp6)] == 1} {
            log.test "DNS, P-CSCF and PDN IP address Verified"
        } else {
            error.an "DNS, P-CSCF and PDN IP addresses do not match"
        }
		
    }
           
    
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80135
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/9/2016
set pctComp   100
set summary   "Test verifies that PGW address from SWm interface - should take precedence over the configured one"
set descr     "
1.  Stop SWM Server and check if 'Dummy' PGW IP address is not configured on MCC
2.  Change PDN type flag to '2' to make it IPv4Ipv6 session
3.  Start the Packet Capture, Bring up the session and verify the Data
4.  Check if session is active on MCC and find the Tunnel endpoint IP addresses
5.  Filter out gtp packets with source and dest. IP addresses as tunnel endpoint IP addresses"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Stop SWM Server and check if 'Dummy' PGW IP address is not configured on MCC" {
        
        swm init
        swm stop
        sleep 5
        
        set dummyIp "2001:470:8865:4087:87::[format %x [tb _ dut.chassisNumber]]"
        
        dut exec "show running-config service-construct pdngw-list ip-address"
        
        if { [string match $dummyIp [cmd_out dump]] == 0} {
            log.test "PGW address set as $dummyIp"
        } else {
            error.an "Choose different IP address"
        }
        
    }   
        
    runStep "Change PDN type flag to '2' to make it IPv4Ipv6 session" {
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_Address(ProtocolConstants.DI_MIP_HOME_AGENT_ADDRESS," str2 "pgwaddr = AVP_Address(ProtocolConstants.DI_MIP_HOME_AGENT_ADDRESS, \"$dummyIp\");"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_MIP6_AGENT_INFO," str2 "agentinfo = AVP_Grouped(ProtocolConstants.DI_MIP6_AGENT_INFO, \[pgwaddr\]);"
        ePDG:replaceStringSwm str1 "AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDNGWALLOCATIONTYPE," str2 "pdngwalloctype = AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDNGWALLOCATIONTYPE, 0, ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ agentinfo, serviceselection, pdngwalloctype \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
    }
    
    runStep "Start the Packet Capture, Bring up the session and verify the Data" {
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
		ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        
        import_tshark_file
        
    }
    
    runStep "Check if session is active on MCC and find the Tunnel endpoint IP addresses" {
    
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Filter out gtp packets with source and dest. IP addresses as tunnel endpoint IP addresses" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$dummyIp' | grep 'Create Session Request' | wc -l"]
        set csrWrong [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 and ipv6.dst==$ip2' | grep 'Create Session Request' | wc -l"]
        set csrCorrect [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 and ipv6.dst==$ip1' | grep 'Create Session Response' | wc -l"]
        set csResponse [ePDG:store_last_line $out1]
        
        if { $csrWrong == 3 && $csrCorrect == 1 && $csResponse == 1 } {
            log.test "SWM Suggested PGW address takes precedence over the configured one"
        } else {
            error.an "SWM Suggested PGW address does not take precedence over the configured one"
        }
		
        
    }
    
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C229038
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/9/2016
set pctComp   100
set summary   "Test verifies that UE session with IDr as APN and Operation Identifier "
set descr     "
1.  Find the default OI configured on MCC
2.  Change the OI Replacement flag in SWM Python script; Bring up the session, check the data path
3.  Verify that UE received the same OI as set"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Find the default OI configured on MCC" {
        
        swm init
        swm stop
        sleep 5
        
        regexp.an -lineanchor {mnc([-0-9.a-zA-Z_]+)$} [tb _ ue.imsi_nai] - Oi
        set defaultOi "mnc$Oi"
        set newOI "mnc077.mcc888.3gppnetwork.org"
        
    }
    
    runStep "Change the OI Replacement flag in SWM Python script; Bring up the session, check the data path" {
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_3GPP_APNOIREPLACEMENT," str2 "oireplacement = AVP_UTF8String(ProtocolConstants.DI_3GPP_APNOIREPLACEMENT, \"$newOI\", ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ oireplacement, serviceselection \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
		ePDG:ue_tcp6_os $ipsec(ueIp6)
        
    }
    
    runStep "Check if UE receives V6 Attributes" {
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
        if { [regexp.an -lineanchor {^\s*apn-oi\s+([-0-9.a-zA-Z_]+)$} $out - apn_oi] } {
            log.test "ePDG Operational Identifier: $apn_oi"
        } else {
            error.an "Failed to retrieve ePDG Operational Identifier"
        }
        
        if { [regexp.an -lineanchor {^\s*apn-replacement-oi\s+([-0-9.a-zA-Z_]+)$} $out - apn_replacement_oi] } {
            log.test "ePDG Replacement Operational Identifier: $apn_replacement_oi"
        } else {
            error.an "Failed to retrieve ePDG Replacement Operational Identifier"
        }
        
    }
    
    runStep "Verify that UE received the same OI as set" {		
        
        if { [string match $apn_oi $defaultOi] && [string match $apn_replacement_oi $newOI] } {
            log.test "Default OI and OI from SWM matched"
        } else {
            error.an "Unable to match default and SWM assigned OIs"
        }
        
    }
    
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C768088
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/9/2016
set pctComp   100
set summary   "Test verifies that UE requests dual stack but HSS provides IPv4 only for that APN, CSR from ePDG should have only IPv4 (CSCF, DNS) parameters, also check the IKE config payload TS narrowed to IPv4 only"
set descr     "
1.  Change PDN type flag to '0' to make it IPv4 only session
2.  Start the Packet capture, Bring up the session
3.  Check the Data Path & Stop the Packet capture, Decrypt IPSec Packets and Import tshark files
4.  Verify Traffic Selector details for Initiator in Initiator Request
5.  Verify Traffic Selector details for Responder in Initiator Request
6.  Verify Traffic Selector details for Initiator in Responder Response
7.  Verify Traffic Selector details for Responder in Responder Response
8.  Filter out gtp packets with source and verify IPv4 ONLY Requests are there for DNS and P-CSCF in Create Session Request
9.  Filter out gtp packets with source and verify IPv4 ONLY Requests are there for DNS and P-CSCF in Create Session Response
10. Check if UE receives V4 ONLY Attributes"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change PDN type flag to '0' to make it IPv4 only session" {
        
        swm init
        swm stop
        sleep 5
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE," str2 "pdntype = AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE, 0, ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ pdntype, serviceselection \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
    }
    
    runStep "Start the Packet capture, Bring up the session" {
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name SWU-5-1"
        
        #array set ipsec [ePDG:start_ipsec_session]
        
        ue exec "ipsec restart"
        ue closeCli
        ue initCli -4 true
        set ipsecInfo [ue exec "ipsec up epdg" -exitCode 0]

        if { [regexp.an "connection 'epdg' established successfully" $ipsecInfo] } {
            log.test "UE reports: connection 'epdg' established successfully"
        } else {
            error.an "Failed to establish 'epdg' connection"
        }

        if { [regexp.an {installing new virtual IP ([0-9.]+)} $ipsecInfo - ueIpv4 ] } {
            log.test "Found new virtual IPv4 and IPv6: $ueIpv4"
        } else {
            error.an "Failed to retrieve new virtual IPs"
        }

        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { ![string is integer -strict [set pgwid [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one pgw session"
        } else {
            log.test "Found pgw session with id: $pgwid"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*ue-v4-ip-address\s+([0-9.]+)$} $out - ueIp4] } {
            log.test "Found ue-v4-ip-address: $ueIp4"
        } else {
            error.an "Failed to retrieve ue-v4-ip-address"
        }
       
        if { $ueIpv4 == $ueIp4 } {
            log.test "UE IP addresses as reported by UE and MCC match"
        } else {
            error "UE IP addresses as reported by UE ($ueIpv4) and MCC ($ueIp4) do not match"
        }

        set out [ue exec "ip -o addr show up primary scope global"]

        if { [regexp "$ueIp4" $out] } {
            log.test "IP address reported by UE"
        } else {
            error.an "UE does not report the new IP ($ueIp4) as active"
        }
        
    }
     
    runStep "Check the Data Path & Stop the Packet capture, Decrypt IPSec Packets and Import tshark files" {   
        
        ePDG:ue_ping_os $ueIp4
        ePDG:ue_ping_os2 $ueIp4
        ePDG:ue_tcp_os $ueIp4
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"
        
        catch { dut exec shell "scp /var/log/eventlog/SWU-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/SWU-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/SWU-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/SWU-5-1*" }
                
        import_tshark_file
         
    }
    
    runStep "Verify Traffic Selector details for Initiator in Initiator Request" {   
    
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e 'IKE_AUTH MID=01 Initiator Request' | sed -n '1p' | awk '{print \$1}'"]
        #set framenumber [ePDG:store_last_line $out1]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - framenumber
        set packetInfo [ue exec " tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$framenumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Initiator \(44\) # 2\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo - var1] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo - var3] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var5 var6] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var7 var8] == 1 } {
            log.test "Initiator Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Initiator Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
        
    }
    
    runStep "Verify Traffic Selector details for Responder in Initiator Request" {   
        
        if { [regexp.an -all {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Responder \(45\) # 2\"} $packetInfo] == 1 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo - var1] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo - var3] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var5] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var7] == 2 } {
            log.test "Responder Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Responder Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
        
    }
    
    runStep "Verify Traffic Selector details for Initiator in Responder Response" {   
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e 'IKE_AUTH' | grep -e 'Responder Response' | sed '$!d' | awk '{print \$1}'"]
        #set framenumber [ePDG:store_last_line $out1]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - framenumber
        set packetInfo [ue exec " tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$framenumber' -T pdml"]
        
        if { [regexp.an -all {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Initiator \(44\) # 1\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo - var1] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo - var3] == 1 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo] == 0 } {
            log.test "Initiator Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Initiator Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
                
        if { [string match $var1 $ueIp4] && [string match $var3 $ueIp4] } {
            log.test "Start and End IP addresses verified in Initiator TS"
        } else {
            error.an "Unable to verify Start and End IP addresses in Initiator TS"
        }        
        
    }
    
    runStep "Verify Traffic Selector details for Responder in Responder Response" {   
        
        if { [regexp.an -all {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Responder \(45\) # 1\"} $packetInfo] == 1 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo - var5] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo - var7] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo] == 0 } {
            log.test "Responder Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Responder Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
        
        if { [string match $var5 "10.71.48.0"] && [string match $var7 "10.71.48.255"] } {
            log.test "Start and End IP addresses verified in Responder TS"
        } else {
            error.an "Unable to verify Start and End IP addresses in Responder TS"
        }
        
    }
        
        
    runStep "Filter out gtp packets with source and verify IPv4 ONLY Requests are there for DNS and P-CSCF in Create Session Request" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
		set frameNumber [ePDG:store_last_line $out1]
        		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {show=\"Additional Protocol Configuration Options \(APCO\)} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv4 Address Request \(0x000c\)\"} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv6 Address Request \(0x0001\)\"} $packetInfo] == 0 && 
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv4 Address Request \(0x000d\)\"} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv6 Address Request \(0x0003\)\"} $packetInfo] == 0 } {
            log.test "Find IPv4 ONLY Requests for DNS and P-CSCF in Create Session Request"
        } else {
            error.an "Unable to Find IPv4 ONLY Requests for DNS and P-CSCF in Create Session Request"
        }
        
    }
    
    runStep "Filter out gtp packets with source and verify IPv4 ONLY Requests are there for DNS and P-CSCF in Create Session Response" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Response\" | awk  '{print \$1}' | sed -n '1p'"]
		set frameNumber [ePDG:store_last_line $out1]
        		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an -all {show=\"Additional Protocol Configuration Options \(APCO\)} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv4 Address \(0x000c\)\"} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv6 Address \(0x0001\)\"} $packetInfo] == 0 && 
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv4 Address \(0x000d\)\"} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv6 Address \(0x0003\)\"} $packetInfo] == 0 } {
            log.test "Find IPv4 ONLY Response for DNS and P-CSCF in Create Session Response"
        } else {
            error.an "Unable to Find IPv4 ONLY Response for DNS and P-CSCF in Create Session Response"
        }
        
    }
        
    runStep "Check if UE receives V4 ONLY Attributes" {
        
        if { [regexp.an {\s*installing DNS server ([0-9.]+) via resolvconf\s+installing DNS server ([0-9.]+) via resolvconf\s+received P-CSCF server IP ([0-9.]+)\s+received P-CSCF server IP ([0-9.]+)\s+installing new virtual IP ([0-9.]+)} $ipsecInfo - uev4dnsIp1 uev4dnsIp2 uev4pcscfIp1 uev4pcscfIp2 ueip4] } {
            log.test "Found DNS, P-CSCF IPv4 addresses on UE: $uev4dnsIp1 $uev4dnsIp2 $uev4pcscfIp1 $uev4pcscfIp2"
        } else {
            error.an "Failed to retrieve DNS and P-CSCF IPs"
        }
		
    }
    
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C768089:C211487
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/10/2016
set pctComp   100
set summary   "Test verifies that UE requests dual stack but HSS provides IPv6 only for that APN, CSR from ePDG should have only IPv6 (CSCF, DNS) parameters, also check the IKE config payload TS narrowed to IPv6 only"
set descr     "
1.  Change PDN type flag to '1' to make it IPv6 only session
2.  Start the Packet capture, Bring up the session
3.  Check the Data Path & Stop the Packet capture, Decrypt IPSec Packets and Import tshark files
4.  Verify Traffic Selector details for Initiator in Initiator Request
5.  Verify Traffic Selector details for Responder in Initiator Request
6.  Verify Traffic Selector details for Initiator in Responder Response
7.  Verify Traffic Selector details for Responder in Responder Response
8.  Filter out gtp packets with source and verify IPv6 ONLY Requests are there for DNS and P-CSCF in Create Session Request
9.  Filter out gtp packets with source and verify IPv6 ONLY Requests are there for DNS and P-CSCF in Create Session Response
10. Check if UE receives V6 ONLY Attributes"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change PDN type flag to '1' to make it IPv6 only session" {
        
        swm init
        swm stop
        sleep 5
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE," str2 "pdntype = AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDN_TYPE, 1, ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ pdntype, serviceselection \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
    }
    
    runStep "Start the Packet capture, Bring up the session" {
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name SWU-5-1"
        
        #array set ipsec [ePDG:start_ipsec_session]
        
        ue exec "ipsec restart"
        ue closeCli
        ue initCli -4 true
        set ipsecInfo [ue exec "ipsec up epdg" -exitCode 0]

        if { [regexp.an "connection 'epdg' established successfully" $ipsecInfo] } {
            log.test "UE reports: connection 'epdg' established successfully"
        } else {
            error.an "Failed to establish 'epdg' connection"
        }

        if { [regexp.an {installing new virtual IP ([0-9:a-zA-Z]+)} $ipsecInfo - ueIpv6 ] } {
            log.test "Found new virtual IPv6: $ueIpv6"
        } else {
            error.an "Failed to retrieve new virtual IPs"
        }

        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { ![string is integer -strict [set pgwid [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one pgw session"
        } else {
            log.test "Found pgw session with id: $pgwid"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*ue-v6-ip-address\s+([0-9a-zA-Z:]+)$} $out - ueIp6] } {
            log.test "Found ue-v6-ip-address: $ueIp6"
        } else {
            error.an "Failed to retrieve ue-v6-ip-address"
        }
        
        regexp.an -lineanchor {^\s*ue-v6-ip-address\s+([0-9a-zA-Z]+):([0-9a-zA-Z]+):([0-9a-zA-Z]+):([0-9a-zA-Z]+)::} $out - a b c d
        set ueIpRange "$a:$b:$c:$d"
        set listofstrings [list "$ueIpRange" "::"]
        set ueIpRange [join $listofstrings ""]
       
        if { $ueIpv6 == $ueIp6 } {
            log.test "UE IP addresses as reported by UE and MCC match"
        } else {
            error "UE IP addresses as reported by UE ($ueIpv6) and MCC ($ueIp6) do not match"
        }

        set out [ue exec "ip -o addr show up primary scope global"]

        if { [regexp "$ueIp6" $out] } {
            log.test "IP address reported by UE"
        } else {
            error.an "UE does not report the new IP ($ueIp6) as active"
        }
        
    }
     
    runStep "Check the Data Path & Stop the Packet capture, Decrypt IPSec Packets and Import tshark files" {   
        
        ePDG:ue_ping6_os $ueIp6
        ePDG:ue_ping6_os2 $ueIp6
        ePDG:ue_tcp6_os $ueIp6
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"
       
        catch { dut exec shell "scp /var/log/eventlog/SWU-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/SWU-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/SWU-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/SWU-5-1*" }
       
        import_tshark_file
         
    }
    
    runStep "Verify Traffic Selector details for Initiator in Initiator Request" {   
    
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' | grep -e 'IKE_AUTH MID=01 Initiator Request' | sed -n '1p' | awk '{print \$1}'"]
        #set framenumber [ePDG:store_last_line $out1]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - framenumber
        set packetInfo [ue exec " tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$framenumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Initiator \(44\) # 2\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo - var1] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo - var3] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var5] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var7] == 1 } {
            log.test "Initiator Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Initiator Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
        
    }
    
    runStep "Verify Traffic Selector details for Responder in Initiator Request" {   
        
        if { [regexp.an -all {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Responder \(45\) # 2\"} $packetInfo] == 1 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo - var1] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo - var3] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var5] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var7] == 2 } {
            log.test "Responder Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Responder Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
        
    }
    
    runStep "Verify Traffic Selector details for Initiator in Responder Response" {   
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e 'IKE_AUTH' | grep -e 'Responder Response' | sed '$!d' | awk '{print \$1}'"]
        #set framenumber [ePDG:store_last_line $out1]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - framenumber
        set packetInfo [ue exec " tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$framenumber' -T pdml"]
        
        if { [regexp.an -all {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Initiator \(44\) # 1\"} $packetInfo] == 1 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo]  == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo] == 0 &&
             [regexp.an {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var1] == 1 &&
             [regexp.an {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var3] == 1 } {
            log.test "Initiator Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Initiator Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
                
        if { [string match $var1 $ueIpRange] } {
            log.test "Start and End IP addresses verified in Initiator TS"
        } else {
            error.an "Unable to verify Start and End IP addresses in Initiator TS"
        }        
        
    }
    
    runStep "Verify Traffic Selector details for Responder in Responder Response" {   
        
        if { [regexp.an -all {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Traffic Selector - Responder \(45\) # 1\"} $packetInfo] == 1 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV4_ADDR_RANGE \(7\)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv4\" showname=\"Starting Addr: ([0-9.]+)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv4\" showname=\"Ending Addr: ([0-9.]+)\"} $packetInfo] == 0 &&
             [regexp.an -all {<field name=\"isakmp.ts.type\" showname=\"Traffic Selector Type: TS_IPV6_ADDR_RANGE \(8\)\"} $packetInfo] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.start_ipv6\" showname=\"Starting Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var5] == 2 &&
             [regexp.an -all {<field name=\"isakmp.ts.end_ipv6\" showname=\"Ending Addr: ([0-9:a-zA-Z]+)\"} $packetInfo - var7] == 2 } {
            log.test "Responder Packet for Traffic Selector Verified"
        } else {
            error.an "Unable to verify Responder Traffic selector Packet: Expectes is both v4 and v6 requests should present"
        }
        
        if { [string match $var5 "2001:470:8865::"] && [string match $var7 "2001:470:8865:ffff:ffff:ffff:ffff:ffff"] } {
            log.test "Start and End IP addresses verified in Responder TS"
        } else {
            error.an "Unable to verify Start and End IP addresses in Responder TS"
        }
        
    }
        
        
    runStep "Filter out gtp packets with source and verify IPv4 ONLY Requests are there for DNS and P-CSCF in Create Session Request" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {show=\"Additional Protocol Configuration Options \(APCO\)} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv4 Address Request \(0x000c\)\"} $packetInfo] == 0 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv6 Address Request \(0x0001\)\"} $packetInfo] == 1 && 
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv4 Address Request \(0x000d\)\"} $packetInfo] == 0 &&
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv6 Address Request \(0x0003\)\"} $packetInfo] == 1 } {
            log.test "Find IPv6 ONLY Requests for DNS and P-CSCF in Create Session Request"
        } else {
            error.an "Unable to Find IPv6 ONLY Requests for DNS and P-CSCF in Create Session Request"
        }
        
    }
    
    runStep "Filter out gtp packets with source and verify IPv4 ONLY Requests are there for DNS and P-CSCF in Create Session Response" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Response\" | awk  '{print \$1}' | sed -n '1p'"]
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an -all {show=\"Additional Protocol Configuration Options \(APCO\)} $packetInfo] == 1 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv4 Address \(0x000c\)\"} $packetInfo] == 0 &&
             [regexp.an {showname=\"Protocol or Container ID: P-CSCF IPv6 Address \(0x0001\)\"} $packetInfo] == 1 && 
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv4 Address \(0x000d\)\"} $packetInfo] == 0 &&
             [regexp.an {showname=\"Protocol or Container ID: DNS Server IPv6 Address \(0x0003\)\"} $packetInfo] == 1 } {
            log.test "Find IPv6 ONLY Response for DNS and P-CSCF in Create Session Response"
        } else {
            error.an "Unable to Find IPv6 ONLY Response for DNS and P-CSCF in Create Session Response"
        }
        
    }
        
    runStep "Check if UE receives V6 ONLY Attributes" {
        
        if { [regexp.an {\s*installing DNS server ([0-9:a-zA-Z]+) via resolvconf\s+installing DNS server ([0-9:a-zA-Z]+) via resolvconf\s+received P-CSCF server IP ([0-9:a-zA-Z]+)\s+received P-CSCF server IP ([0-9:a-zA-Z]+)\s+installing new virtual IP ([0-9:a-zA-Z]+)} $ipsecInfo - uev6dnsIp1 uev6dnsIp2 uev6pcscfIp1 uev6pcscfIp2 ueip6] } {
            log.test "Found DNS, P-CSCF IPv6 addresses on UE: $uev6dnsIp1 $uev6dnsIp2 $uev6pcscfIp1 $uev6pcscfIp2"
        } else {
            error.an "Failed to retrieve DNS and P-CSCF IPs"
        }
		
    }
    
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
    if { $i == 0 } {
        set id        ePDG:section1:EPDG:C80180:C341230:C97007:C80183
    } else {
        set id        ePDG:section1:EPDG:C80181:C341231:C80182
    }
set category  "Basic NAT and NAT-T & Fragmentation and Reassembly"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   1/6/2017
set pctComp   100
set summary   "This Test verifies One session with IPv4/IPv6 data - NAT'ed and large packets to ePDG (send large ping 2400 bytes) & Fragmentation and Reassembly"
set descr     "
1.  Change the fields in ipsec.conf in UE, add a route and start the Packet Capture
2.  Check the Data Path with default and large packets
3.  Stop the Packet Capture, decrypt the IPSEC Packets and Import the PCAP
4.  Verifiy Source and Destination Port as 500 in IKE_SA_INIT Initiator Request
5.  Verifiy Source and Destination Port as 500 in IKE_SA_INIT Responder Response
6.  Verifiy Source and Destination Port as 4500 in IKE_AUTH Initiator Request
7.  Verifiy Source and Destination Port as 4500 in IKE_AUTH Responder Response
8.  Verify the count for ESP - ICMP Fragmanted & Reassembled Data Packets
9.  Verify All ESP - Data Packets are passing through Port # 4500 (UE is behind the NAT)"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the fields in ipsec.conf in UE, add a route and start the Packet Capture" {
        
        ue exec "sed -i 's/#*left=[tb _ ue.ip]/left=[tb _ ue.ip2]/g' /etc/ipsec.conf"
        
        ue exec "route del [tb _ dut.SWU-LB-V4]/32 gw [tb _ nat.gw]"
        ue exec "route add [tb _ dut.SWU-LB-V4]/32 gw [tb _ nat.ip2]"
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 20000 duration 600 file-name umakant"
        
    }
    
    runStep "Check the Data Path with default and large packets" {
        
        if { $i == 0 } {
            
            array set ipsec [ePDG:start_ipsecv4_session]
            ePDG:ue_ping_os $ipsec(ueIp4)
            ePDG:ue_ping_os2 $ipsec(ueIp4)
            ePDG:ue_tcp_os $ipsec(ueIp4)
            
            catch {ue exec "ping -I $ipsec(ueIp4) [tb _ os.ip] -c 5 -s 2400 -i 0.2"} result
		
            if { [regexp.an " 0% packet loss" $result] } {
                log.test "Data Tarnsferred Successfully, without any loss"
            } elseif { [regexp.an " 100% packet loss" $result] } {
                error.an "100% Packet loss during ICMP Ping; Unable to transfer Data"
            } else {
                error.an "Packet loss during ICMP Ping; Retry"
            }
            
            catch {ue exec "ping -I $ipsec(ueIp4) [tb _ os2.ip] -c 5 -s 2400 -i 0.2"} result
            
            if { [regexp.an " 0% packet loss" $result] } {
                log.test "Data Tarnsferred Successfully, without any loss"
            } elseif { [regexp.an " 100% packet loss" $result] } {
                error.an "100% Packet loss during ICMP Ping; Unable to transfer Data"
            } else {
                error.an "Packet loss during ICMP Ping; Retry"
            }
            
        } else {
            
            array set ipsec [ePDG:start_ipsecv6_session]
            ePDG:ue_ping6_os $ipsec(ueIp6)
            ePDG:ue_ping6_os2 $ipsec(ueIp6)
            ePDG:ue_tcp6_os $ipsec(ueIp6)
            
            catch {ue exec "ping6 -I $ipsec(ueIp6) [tb _ os.ipv6] -c 5 -s 2400 -i 0.2"} result
            
            catch {ue exec "ping6 -I $ipsec(ueIp6) [tb _ os.ipv6] -c 5 -s 2400 -i 0.2"} result
		
            if { [regexp.an " 0% packet loss" $result] } {
                log.test "Data Tarnsferred Successfully, without any loss"
            } elseif { [regexp.an " 100% packet loss" $result] } {
                error.an "100% Packet loss during ICMP Ping; Unable to transfer Data"
            } else {
                error.an "Packet loss during ICMP Ping; Retry"
            }
            
            catch {ue exec "ping6 -I $ipsec(ueIp6) [tb _ os2.ipv6] -c 5 -s 2400 -i 0.2"} result
            
            catch {ue exec "ping6 -I $ipsec(ueIp6) [tb _ os2.ipv6] -c 5 -s 2400 -i 0.2"} result
            
            if { [regexp.an " 0% packet loss" $result] } {
                log.test "Data Tarnsferred Successfully, without any loss"
            } elseif { [regexp.an " 100% packet loss" $result] } {
                error.an "100% Packet loss during ICMP Ping; Unable to transfer Data"
            } else {
                error.an "Packet loss during ICMP Ping; Retry"
            }
        }
        
    }
    
    runStep "Stop the Packet Capture, decrypt the IPSEC Packets and Import the PCAP" {
        
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        ue exec "ipsec restart"        
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
        
    }
    
    runStep "Verifiy Source and Destination Port as 500 in IKE_SA_INIT Initiator Request" {
    
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V4 ip-address"]
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - epdg_swu_lbv4
        
		set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==[tb _ nat.ip] and ip.dst==$epdg_swu_lbv4' | grep -e 'IKE_SA_INIT MID=00 Initiator Request' | sed -n '1p' | awk  '{print \$1}'"]
		set frameNumber [ePDG:store_last_line $out1]
        
        set PacketInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<proto name=\"udp\" showname=\"User Datagram Protocol, Src Port: 500 \(500\), Dst Port: 500 \(500\)\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.srcport\" showname=\"Source Port: 500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.dstport\" showname=\"Destination Port: 500\"} $PacketInfo] == 1 && 
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 500\"} $PacketInfo] == 1 } {
            log.test "Verified Source and Destination Port as 500 in IKE_SA_INIT Initiator Request"
        } else {
            error.an "Unable to find Source and Destination Port as 500 in IKE_SA_INIT Initiator Request"
        }
        
    }
    
    runStep "Verifiy Source and Destination Port as 500 in IKE_SA_INIT Responder Response" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$epdg_swu_lbv4 and ip.dst==[tb _ nat.ip]' | grep -e 'IKE_SA_INIT MID=00 Responder Response' | sed -n '1p' | awk  '{print \$1}'"]
		set frameNumber [ePDG:store_last_line $out1]
        
        set PacketInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<proto name=\"udp\" showname=\"User Datagram Protocol, Src Port: 500 \(500\), Dst Port: 500 \(500\)\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.srcport\" showname=\"Source Port: 500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.dstport\" showname=\"Destination Port: 500\"} $PacketInfo] == 1 && 
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 500\"} $PacketInfo] == 1 } {
            log.test "Verified Source and Destination Port as 500 in IKE_SA_INIT Responder Response"
        } else {
            error.an "Unable to find Source and Destination Port as 500 in IKE_SA_INIT Responder Response"
        }
        
    }
    
    runStep "Verifiy Source and Destination Port as 4500 in IKE_AUTH Initiator Request" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' | grep -e 'IKE_AUTH MID=01 Initiator Request' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - framenumber
        
        set PacketInfo [ue exec " tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$framenumber' -T pdml"]
        
        if { [regexp.an {<proto name=\"udp\" showname=\"User Datagram Protocol, Src Port: 4500 \(4500\), Dst Port: 4500 \(4500\)\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.srcport\" showname=\"Source Port: 4500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.dstport\" showname=\"Destination Port: 4500\"} $PacketInfo] == 1 && 
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 4500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 4500\"} $PacketInfo] == 1 } {
            log.test "Verified Source and Destination Port as 4500 in IKE_AUTH Initiator Request"
        } else {
            error.an "Unable to find Source and Destination Port as 4500 in IKE_AUTH Initiator Request"
        }
        
    }
    
    runStep "Verifiy Source and Destination Port as 4500 in IKE_AUTH Responder Response" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp' |  grep -e 'IKE_AUTH' | grep -e 'Responder Response' | sed '$!d' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - framenumber
        
        set PacketInfo [ue exec " tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$framenumber' -T pdml"]
        
        if { [regexp.an {<proto name=\"udp\" showname=\"User Datagram Protocol, Src Port: 4500 \(4500\), Dst Port: 4500 \(4500\)\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.srcport\" showname=\"Source Port: 4500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.dstport\" showname=\"Destination Port: 4500\"} $PacketInfo] == 1 && 
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 4500\"} $PacketInfo] == 1 &&
             [regexp.an {<field name=\"udp.port\" showname=\"Source or Destination Port: 4500\"} $PacketInfo] == 1 } {
            log.test "Verified Source and Destination Port as 4500 in IKE_AUTH Responder Response"
        } else {
            error.an "Unable to find Source and Destination Port as 4500 in IKE_AUTH Responder Response"
        }
        
    }
    
    runStep "Verify the count for ESP - ICMP Fragmanted & Reassembled Data Packets" {
        
        if { $i == 0 } {
            
            set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmp and ip.src==[tb _ nat.ip] and ip.dst==$epdg_swu_lbv4' | grep 'request' | wc -l"]
            regexp.an -all -lineanchor {\s([0-9]+)} $out1 - c1
            set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmp and ip.src==$epdg_swu_lbv4 and ip.dst==[tb _ nat.ip]' | grep 'request' | wc -l"]
            regexp.an -all -lineanchor {\s([0-9]+)} $out1 - c2
            
            if { [string match $c1 $c2] == 1 && [string match $c1 "20"] == 1} {
                log.test "All ESP - Data Packets are getting fragmanted"
            } else {
                error.an "All ESP - Data Packets are not getting fragmanted"
            }
            
        } else {
            
            set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmpv6 and ip.src==[tb _ nat.ip] and ip.dst==$epdg_swu_lbv4' | grep 'request' | wc -l"]
            regexp.an -all -lineanchor {\s([0-9]+)} $out1 - c1
            set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmpv6 and ip.src==$epdg_swu_lbv4 and ip.dst==[tb _ nat.ip]' | grep 'request' | wc -l"]
            regexp.an -all -lineanchor {\s([0-9]+)} $out1 - c2
            
            if { [string match $c1 "30"] == 1 && [string match $c2 "28"] == 1} {
                log.test "All ESP - Data Packets are getting fragmanted"
            } else {
                error.an "All ESP - Data Packets are not getting fragmanted"
            }
            
        }
        
    }
    
    runStep "Verify All ESP - Data Packets are passing through Port # 4500 (UE is behind the NAT)" {
        
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and udp.port==4500' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - espCount1
        set out2 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - espCount2
        
        if { [string match $espCount1 $espCount2] == 1 } {
            log.test "All ESP - Data Packets are passing through Port # 4500 (UE is behind the NAT)"
        } else {
            error.an "All ESP - Data Packets are not passing through Port # 4500 UE is not behind the NAT"
        }
        
    }
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ue exec "route del [tb _ dut.SWU-LB-V4]/32 gw [tb _ nat.ip2]"
    ue exec "route add [tb _ dut.SWU-LB-V4]/32 gw [tb _ nat.gw]"
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    ePDG:mcc_crash_checkup
}

}

# ==============================================================
set id        ePDG:section1:EPDG:C339689
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/18/2016
set pctComp   100
set summary   "This test verifies that aes128gcm8 transform can be negotiated and session comes up fine and ping data works"
set descr     "
1.  Change the Certificate type from to aes128gcm8 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from to aes128gcm8 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128gcm8-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_GCM_8_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_GCM_8_128," $out] ==1} {
            log.test "aes128gcm8 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes128gcm8 ESP Transform"
        }
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-gcm-64/128 - None"] == 1 } {
            log.test "aes128gcm8 ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes128gcm8 ESP Transform on MCC"
        }
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C339690
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/18/2016
set pctComp   100
set summary   "This test verifies that aes128gcm16 transform can be negotiated and session comes up fine and ping data works"
set descr     "
1.  Change the Certificate type from to aes128gcm16 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from to aes128gcm16 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128gcm16-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_GCM_16_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_GCM_16_128," $out] ==1} {
            log.test "aes128gcm16 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes128gcm16 ESP Transform"
        }
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-gcm/128 - None"] == 1 } {
            log.test "aes128gcm16 ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes128gcm16 ESP Transform on MCC"
        }
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C339691
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/18/2016
set pctComp   100
set summary   "This test verifies that aes192gcm8 transform can be negotiated and session comes up fine and ping data works"
set descr     "
1.  Change the Certificate type from to aes192gcm8 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from to aes192gcm8 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192gcm8-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_GCM_8_192/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_GCM_8_192," $out] ==1} {
            log.test "aes192gcm8 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes192gcm8 ESP Transform"
        }
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-gcm-64/192 - None"] == 1 } {
            log.test "aes192gcm8 ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes192gcm8 ESP Transform on MCC"
        }
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C339694
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/18/2016
set pctComp   100
set summary   "This test verifies that aes256gcm16 transform can be negotiated and session comes up fine and ping data works"
set descr     "
1.  Change the Certificate type from to aes256gcm16 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from to aes256gcm16 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256gcm16-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_GCM_16_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_GCM_16_256," $out] ==1} {
            log.test "aes256gcm16 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes256gcm16 ESP Transform"
        }
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-gcm/256 - None"] == 1 } {
            log.test "aes256gcm16 ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes256gcm16 ESP Transform on MCC"
        }
        
    }
    
} {
    # Cleanup 
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80177
set category  "IPv6 Transport and UE with IPv4 data"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/18/2016
set pctComp   100
set summary   "Test verifies session with ePDG and UE's control n/w using IPv6 but GTP-c on IPv6 - AES256-SHA2-256-DH14 - UE data on IPv4"
set descr     "
1.  Get ePDG and PGW addresses configured on MCC
2.  Change the left and right fileds in ipsec.conf on UE to IPv6 addresses
3.  Get the Weights for PGW IPv4 and IPv6 addresses configured on MCC
4.  Check if weight for IPv6 is more than IPv4; if not alter those values
5.  Capture the Packets and start the session
6.  Import SWU-interface Tshark file
7.  Verify if control path from UE is IPv6 i.e, All ISAKMP packets have IPv6 address
8.  Verify if data path from UE is IPv6 i.e, All ESP packets have IPv4 address
9.  Import S2B-interface Tshark file
10. Get the Source and Destination IP addresses of the GTP-C messages
11. Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
12. Find out the Ping Packets from UE to OS to verify IPv4 data path on S2B interface
13. Import GI-interface Tshark file
14. Find out the Ping Packets from UE to OS to verify IPv4 data path on GI interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Get ePDG and PGW IPv4 and IPv6 addresses (on SWU interface) from MCC" {
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - epdg_swu_lbv4
        
        set ip_info [dut exec "show running-config network-context SWU loopback-ip EPDG-LB-V6 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9:a-z]+)} $ip_info - epdg_swu_lbv6
        
        set ip_info [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_lb_v4
        
        set ip_info [dut exec "show running-config network-context S2B-PGW loopback-ip PGW-LB-V6 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9:a-z]+)} $ip_info - pgw_lb_v6
       
    }
        
    runStep "Change the left and right fileds in ipsec.conf on UE to IPv6 addresses" {
        
        #catch {ue exec "ip addr flush eth1"}
        #catch {ue exec "systemctl restart networking.service"}
        #ue closeCli
        #ue initCli -4 true
        #ue exec "ipsec restart"
        
        ue exec "sed -i 's/#*left=[tb _ ue.ip]/left=[tb _ ue.ipv6]/g' /etc/ipsec.conf"
        
        ue exec "sed -i 's/#*right=$epdg_swu_lbv4/right=$epdg_swu_lbv6/g' /etc/ipsec.conf"
        
    }
        
    runStep "Get the Weights for PGW IPv4 and IPv6 addresses configured on MCC" {

        set pgw_ipv4_info [dut exec "show running-config service-construct pdngw-list PDNGW-LIST-1 ip-address $pgw_lb_v4 weight"]
        
        regexp.an {\s*weight\s([0-9]+)} $pgw_ipv4_info - weight_v4
        
        set pgw_ipv6_info [dut exec "show running-config service-construct pdngw-list PDNGW-LIST-1 ip-address $pgw_lb_v6 weight"]
        
        regexp.an {\s*weight\s([0-9]+)} $pgw_ipv6_info - weight_v6
        
    }
    
    runStep "Check if weight for IPv6 is more than IPv4; if not alter those values" {

        if { $weight_v6 > $weight_v4 } {
            log.test "Default IP connection type is IPv6"
        } else {
            puts "Weight for IPv4 '$weight_v4' is more than that of IPv6 '$weight_v6'; Change the configuration and try again"
        }
    }
    
    runStep "Capture the Packets and start the session" {

        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name SWU-5-1"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 1000 duration 600 file-name S2B-EPDG-5-1"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 startcapture count 1000 duration 600 file-name GI-QA-5-1"
                
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        dut exec "network-context GI-QA ip-interface GI-QA-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
    }
    
    runStep "Check the IPSec status and verify the Security certificate" {
        
        set out [ue exec "ipsec statusall"]

        if { [regexp.an "AES_CBC_256/HMAC_SHA2_256_128," $out] } {
            log.test "x509 2048 byte certificate - AES256/SHA2-256 Found"
        } else {
            error.an "No Matching Encryption algorithm found for IPSec session"
        }
        
    }
    
# ==========================================================================================================================================================================================    
    runStep "Import SWU-interface Tshark file" {
            
        catch { dut exec shell "scp /var/log/eventlog/SWU-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/SWU-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/SWU-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/SWU-5-1*" }
        
    }
    
    runStep "Verify if control path from UE is IPv6 i.e, All ISAKMP packets have IPv6 address" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'isakmp'"
       
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp and ipv6.addr==[tb _ ue.ipv6] and ipv6.addr==$epdg_swu_lbv6' | grep 'IKE_SA_INIT' | wc -l"]
		regexp.an -all -lineanchor {\s*([0-9]+)} $out1 - ikesa_packet_count
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'isakmp and ipv6.addr==[tb _ ue.ipv6] and ipv6.addr==$epdg_swu_lbv6' | grep 'IKE_AUTH' | wc -l"]
		regexp.an -all -lineanchor {\s*([0-9]+)} $out1 - ikeauth_packet_count
        
        if { $ikesa_packet_count >= 2 && $ikeauth_packet_count >= 2 } {
            log.test "ISAKMP IP Packets are present with mentioned IP addersses;Control n/w from UE is IPv4"
        } else {
            error.an "Mentioned IP addresses in tshark filter are not present in ALL ISAKMP Messages;Control n/w from UE is not IPv4"
        }
       
    }
    
    runStep "Verify if data path from UE is IPv4 i.e, All ESP/ICMPv4 packets have IPv4 address" {
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'esp and icmp and ip.addr==$ipsec(ueIp4) and ip.addr==[tb _ os.ip]' | wc -l"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - esp_packet_count
		        
        if { $esp_packet_count == 10 } {
            log.test "ESP IP Packets are present with mentioned IP addersses;Data n/w from UE is IPv4"
        } else {
            error.an "Mentioned IP addresses in tshark filter are not present in ALL ESP Messages;Data n/w from UE is not IPv4"
        }
       
        catch {tshark exec "rm /tmp/umakant"}
        catch {ue exec "rm /usr/share/wireshark/umakant"}
    }
# ==========================================================================================================================================================================================        
    runStep "Import S2B-interface Tshark file" {
        
        catch { dut exec shell "scp /var/log/eventlog/S2B-EPDG-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/S2B-EPDG-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*" }
        
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_pgw
        
        if { [string match $ip1 $ip_epdg] == 1 && [string match $ip2 $ip_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv4 data path on S2B interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipsec(ueIp4) and ip.addr==[tb _ os.ip]'"
         
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmp and ip.addr==$ipsec(ueIp4) and ip.addr==[tb _ os.ip]' | wc -l"]
        set ping_packet_count [ePDG:store_last_line $out1]
        
        if { $ping_packet_count == 10 } {
            log.test "Data path between UE and OS on S2B is IPv4"
        } else {
            error.an "Data path between UE and OS is not IPv4 on S2B Interface"
        }
        
        catch {tshark exec "rm /tmp/umakant"}
    }
# ==========================================================================================================================================================================================    
    runStep "Import GI-interface Tshark file" {
            
        catch { dut exec shell "scp /var/log/eventlog/GI-QA-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/GI-QA-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/GI-QA-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ tshark.user]@[tb _ tshark.host]:/tmp/umakant" -password [tb _ tshark.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/GI-QA-5-1*" }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv4 data path on GI interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipsec(ueIp4) and ip.addr==[tb _ os.ip]'"
         
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'icmp and ip.addr==$ipsec(ueIp4) and ip.addr==[tb _ os.ip]' | wc -l"]
        set packet_count [ePDG:store_last_line $out1]
        
        if { $packet_count == 10 } {
            log.test "Data path between UE and OS on GI is IPv4"
        } else {
            error.an "Data path between UE and OS is not IPv4 on GI Interface"
        }
        
        catch {tshark exec "rm /tmp/umakant"}
        
    }

} {
    # Cleanup
    #catch {ue exec "ip addr flush eth1"}
    #catch {ue exec "systemctl restart networking.service"}
    #ue closeCli
    #ue initCli -4 true
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    catch {dut exec shell "rm /var/log/eventlog/GI-QA-5-1*"}
    catch {dut exec shell "rm /var/log/eventlog/SWU-5-1*"}
    catch {dut exec shell "rm /var/log/eventlog/S2B-EPDG-5-1*"}
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
    
}

# ==============================================================  
set id        ePDG:section1:EPDG:C778858
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/22/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as 3des-192-sha1-160-96"
set descr     "
1.  Change the Certificate type from to 3des-192-sha1-160-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from to aes256gcm16 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=3des-sha1-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=3des-sha1-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "3DES_CBC/HMAC_SHA1_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "3DES_CBC/HMAC_SHA1_96," $out] ==1 } {
            log.test "3des-192-sha1-160-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha1-160-96 ESP Transform"
        }
        
        if { [string match $certike "3DES_CBC/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: 3DES_CBC/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048" $out] ==1 } {
            log.test "3des-192-sha1-160-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha1-160-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "3des-cbc - hmac-sha1-96"] == 1 && [string match $ikeAlgo "3des-cbc, hmac-sha1, hmac-sha1-96"] ==1 } {
            log.test "3des-192-sha1-160-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate 3des-192-sha1-160-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778859
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as 3des-192-sha2-256-128"
set descr     "
1.  Change the Certificate type to 3des-192-sha2-256-128 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type from to aes256gcm16 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=3des-sha256-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=3des-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "3DES_CBC/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "3DES_CBC/HMAC_SHA2_256_128," $out] ==1 } {
            log.test "3des-192-sha2-256-128 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-256-128 ESP Transform"
        }
        
        if { [string match $certike "3DES_CBC/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: 3DES_CBC/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048" $out] ==1 } {
            log.test "3des-192-sha2-256-128 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-256-128 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "3des-cbc - hmac-sha256-128"] == 1 && [string match $ikeAlgo "3des-cbc, hmac-sha256, hmac-sha256-128"] ==1 } {
            log.test "3des-192-sha2-256-128 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-256-128 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778860
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as 3des-192-sha2-384-192"
set descr     "
1.  Change the Certificate type from to 3des-192-sha2-384-192 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to 3des-192-sha2-384-192 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=3des-sha384-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=3des-sha384-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "3DES_CBC/HMAC_SHA2_384_192/NO_EXT_SEQ"] == 1 && [regexp.an -all "3DES_CBC/HMAC_SHA2_384_192," $out] ==1 } {
            log.test "3des-192-sha2-384-192 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-384-192 ESP Transform"
        }
        
        if { [string match $certike "3DES_CBC/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: 3DES_CBC/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048" $out] ==1 } {
            log.test "3des-192-sha2-384-192 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-384-192 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "3des-cbc - hmac-sha384-192"] == 1 && [string match $ikeAlgo "3des-cbc, hmac-sha384, hmac-sha384-192"] ==1 } {
            log.test "3des-192-sha2-384-192 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-384-192 IKE & ESP Transform on MCC"
        }
        
    }
    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================    
set id        ePDG:section1:EPDG:C778861
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as 3des-192-sha2-512-256"
set descr     "
1.  Change the Certificate type from to 3des-192-sha2-512-256 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to 3des-192-sha2-512-256 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=3des-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=3des-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "3DES_CBC/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "3DES_CBC/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "3des-192-sha2-512-256 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-512-256 ESP Transform"
        }
        
        if { [string match $certike "3DES_CBC/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: 3DES_CBC/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "3des-192-sha2-512-256 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-512-256 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "3des-cbc - hmac-sha512-256"] == 1 && [string match $ikeAlgo "3des-cbc, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "3des-192-sha2-512-256 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate 3des-192-sha2-512-256 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778864
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as 3des-192-md5-128-96"
set descr     "
1.  Change the Certificate type from to 3des-192-md5-128-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to 3des-192-md5-128-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=3des-md5-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=3des-md5-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "3DES_CBC/HMAC_MD5_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "3DES_CBC/HMAC_MD5_96," $out] ==1 } {
            log.test "3des-192-md5-128-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-md5-128-96 ESP Transform"
        }
        
        if { [string match $certike "3DES_CBC/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: 3DES_CBC/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048" $out] ==1 } {
            log.test "3des-192-md5-128-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-md5-128-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "3des-cbc - hmac-md5-96"] == 1 && [string match $ikeAlgo "3des-cbc, hmac-md5, hmac-md5-96"] ==1 } {
            log.test "3des-192-md5-128-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate 3des-192-md5-128-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================   
set id        ePDG:section1:EPDG:C778895
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as 3des-192-aes-xcbc"
set descr     "
1.  Change the Certificate type from to 3des-192-aes-xcbc in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to 3des-192-aes-xcbc in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=3des-aesxcbc-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=3des-aesxcbc-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "3DES_CBC/AES_XCBC_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "3DES_CBC/AES_XCBC_96," $out] ==1 } {
            log.test "3des-192-aes-xcbc ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-aes-xcbc ESP Transform"
        }
        
        if { [string match $certike "3DES_CBC/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: 3DES_CBC/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048" $out] ==1 } {
            log.test "3des-192-aes-xcbc IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate 3des-192-aes-xcbc IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "3des-cbc - xcbc-aes-96"] == 1 && [string match $ikeAlgo "3des-cbc, xcbcmac-aes, xcbcmac-aes-96"] ==1 } {
            log.test "3des-192-aes-xcbc IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate 3des-192-aes-xcbc IKE & ESP Transform on MCC"
        }
        
    }
        
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778865
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-128-sha1-160-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-sha1-160-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-sha1-160-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-sha1-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-sha1-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/HMAC_SHA1_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/HMAC_SHA1_96," $out] ==1 } {
            log.test "aes-cbc-128-sha1-160-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-128-sha1-160-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - hmac-sha1-96"] == 1 && [string match $ikeAlgo "aes128-cbc, hmac-sha1, hmac-sha1-96"] ==1 } {
            log.test "aes-cbc-128-sha1-160-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 IKE & ESP Transform on MCC"
        }
        
    }
        
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80119
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   01/06/2017
set pctComp   100
set summary   "ePDG session on MCC - DH1/x509 768 byte certificate - AES128/SHA1-160-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-sha1-160-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-sha1-160-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-sha1-modp768!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-sha1-modp768!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/HMAC_SHA1_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/HMAC_SHA1_96," $out] ==1 } {
            log.test "aes-cbc-128-sha1-160-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_768"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_768" $out] ==1 } {
            log.test "aes-cbc-128-sha1-160-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        regexp.an -all {\s*diffie-hellman\s+\"([-0-9A-Z_a-z,\(\)\s]+)\"} $out2 - dhgrp
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - hmac-sha1-96"] == 1 && [string match $ikeAlgo "aes128-cbc, hmac-sha1, hmac-sha1-96"] ==1 && [string match $dhgrp "group 1 (768 bits)"] == 1 } {
            log.test "aes-cbc-128-sha1-160-96 IKE & ESP Transform with 768 bits Certificate negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 IKE & ESP Transform, with 768 bits Certificate on MCC"
        }
        
    }
        
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C80120
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   01/06/2017
set pctComp   100
set summary   "ePDG session on MCC - DH1/x509 1024 byte certificate - AES256/SHA1-160-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-sha1-160-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-sha1-160-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-sha1-modp1024!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-sha1-modp1024!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/HMAC_SHA1_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/HMAC_SHA1_96," $out] ==1 } {
            log.test "aes-cbc-128-sha1-160-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha1-160-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_1024"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_1024" $out] ==1 } {
            log.test "aes-cbc-256-sha1-160-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha1-160-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        regexp.an -all {\s*diffie-hellman\s+\"([-0-9A-Z_a-z,\(\)\s]+)\"} $out2 - dhgrp
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - hmac-sha1-96"] == 1 && [string match $ikeAlgo "aes256-cbc, hmac-sha1, hmac-sha1-96"] ==1 && [string match $dhgrp "group 2 (1024 bits)"] == 1 } {
            log.test "aes-cbc-256-sha1-160-96 IKE & ESP Transform with 1024 bits Certificate negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha1-160-96 IKE & ESP Transform, with 1024 bits Certificate on MCC"
        }
        
    }
        
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778866
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-128-sha2-256-128"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-sha2-256-128 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-sha2-256-128 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-sha256-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/HMAC_SHA2_256_128," $out] ==1 } {
            log.test "aes-cbc-128-sha2-256-128 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-256-128 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-128-sha2-256-128 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-256-128 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - hmac-sha256-128"] == 1 && [string match $ikeAlgo "aes128-cbc, hmac-sha256, hmac-sha256-128"] ==1 } {
            log.test "aes-cbc-128-sha2-256-128 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-256-128 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778867
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-128-sha2-384-192"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-sha2-384-192 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-sha2-384-192 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-sha384-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-sha384-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/HMAC_SHA2_384_192/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/HMAC_SHA2_384_192," $out] ==1 } {
            log.test "aes-cbc-128-sha2-384-192 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-384-192 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-128-sha2-384-192 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-384-192 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - hmac-sha384-192"] == 1 && [string match $ikeAlgo "aes128-cbc, hmac-sha384, hmac-sha384-192"] ==1 } {
            log.test "aes-cbc-128-sha2-384-192 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-384-192 IKE & ESP Transform on MCC"
        }
        
    }
    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778868
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-128-sha2-512-256"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-sha2-512-256 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-sha2-512-256 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "aes-cbc-128-sha2-512-256 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-512-256 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-128-sha2-512-256 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-512-256 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - hmac-sha512-256"] == 1 && [string match $ikeAlgo "aes128-cbc, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "aes-cbc-128-sha2-512-256 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-sha2-512-256 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778869
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-128-md5-128-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-md5-128-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-md5-128-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-md5-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-md5-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/HMAC_MD5_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/HMAC_MD5_96," $out] ==1 } {
            log.test "aes-cbc-128-md5-128-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-md5-128-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-128-md5-128-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-md5-128-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - hmac-md5-96"] == 1 && [string match $ikeAlgo "aes128-cbc, hmac-md5, hmac-md5-96"] ==1 } {
            log.test "aes-cbc-128-md5-128-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-md5-128-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778896
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-128-aes-xcbc"
set descr     "
1.  Change the Certificate type from to aes-cbc-128-aes-xcbc in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-128-aes-xcbc in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128-aesxcbc-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128-aesxcbc-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_128/AES_XCBC_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_128/AES_XCBC_96," $out] ==1 } {
            log.test "aes-cbc-128-aes-xcbc ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-aes-xcbc ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_128/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_128/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-128-aes-xcbc IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-128-aes-xcbc IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/128 - xcbc-aes-96"] == 1 && [string match $ikeAlgo "aes128-cbc, xcbcmac-aes, xcbcmac-aes-96"] ==1 } {
            log.test "aes-cbc-128-aes-xcbc IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-128-aes-xcbc IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778870
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-192-sha1-160-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-192-sha1-160-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-192-sha1-160-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192-sha1-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-sha1-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_SHA1_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_SHA1_96," $out] ==1 } {
            log.test "aes-cbc-192-sha1-160-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha1-160-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_192/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_192/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-192-sha1-160-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha1-160-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/192 - hmac-sha1-96"] == 1 && [string match $ikeAlgo "aes192-cbc, hmac-sha1, hmac-sha1-96"] ==1 } {
            log.test "aes-cbc-192-sha1-160-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha1-160-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778871
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-192-sha2-256-128"
set descr     "
1.  Change the Certificate type from to aes-cbc-192-sha2-256-128 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-192-sha2-256-128 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192-sha256-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_SHA2_256_128," $out] ==1 } {
            log.test "aes-cbc-192-sha2-256-128 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-256-128 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_192/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_192/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-192-sha2-256-128 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-256-128 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/192 - hmac-sha256-128"] == 1 && [string match $ikeAlgo "aes192-cbc, hmac-sha256, hmac-sha256-128"] ==1 } {
            log.test "aes-cbc-192-sha2-256-128 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-256-128 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778872
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-192-sha2-384-192"
set descr     "
1.  Change the Certificate type from to aes-cbc-192192-sha2-384-192 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-192-sha2-384-192 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192-sha384-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-sha384-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_SHA2_384_192/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_SHA2_384_192," $out] ==1 } {
            log.test "aes-cbc-192-sha2-384-192 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-384-192 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_192/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_192/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-192-sha2-384-192 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-384-192 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/192 - hmac-sha384-192"] == 1 && [string match $ikeAlgo "aes192-cbc, hmac-sha384, hmac-sha384-192"] ==1 } {
            log.test "aes-cbc-192-sha2-384-192 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-384-192 IKE & ESP Transform on MCC"
        }
        
    }
        
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778873
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-192-sha2-512-256"
set descr     "
1.  Change the Certificate type from to aes-cbc-192-sha2-512-256 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-192-sha2-512-256 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "aes-cbc-192-sha2-512-256 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-512-256 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_192/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_192/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-192-sha2-512-256 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-512-256 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/192 - hmac-sha512-256"] == 1 && [string match $ikeAlgo "aes192-cbc, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "aes-cbc-192-sha2-512-256 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-192-sha2-512-256 IKE & ESP Transform on MCC"
        }
        
    }
        
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778874
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-192-md5-128-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-192-md5-128-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-192-md5-128-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192-md5-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-md5-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/HMAC_MD5_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/HMAC_MD5_96," $out] ==1 } {
            log.test "aes-cbc-192-md5-128-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-md5-128-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_192/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_192/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-192-md5-128-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-md5-128-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/192 - hmac-md5-96"] == 1 && [string match $ikeAlgo "aes192-cbc, hmac-md5, hmac-md5-96"] ==1 } {
            log.test "aes-cbc-192-md5-128-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-192-md5-128-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778897
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-192-aes-xcbc"
set descr     "
1.  Change the Certificate type from to aes-cbc-192-aes-xcbc in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-192-aes-xcbc in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192-aesxcbc-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192-aesxcbc-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_192/AES_XCBC_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_192/AES_XCBC_96," $out] ==1 } {
            log.test "aes-cbc-192-aes-xcbc ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-aes-xcbc ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_192/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_192/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-192-aes-xcbc IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-192-aes-xcbc IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/192 - xcbc-aes-96"] == 1 && [string match $ikeAlgo "aes192-cbc, xcbcmac-aes, xcbcmac-aes-96"] ==1 } {
            log.test "aes-cbc-192-aes-xcbc IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-192-aes-xcbc IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778875
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-256-sha1-160-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-sha1-160-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-256-sha1-160-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-sha1-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-sha1-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/HMAC_SHA1_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/HMAC_SHA1_96," $out] ==1 } {
            log.test "aes-cbc-256-sha1-160-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha1-160-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA1_96/PRF_HMAC_SHA1/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-256-sha1-160-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha1-160-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - hmac-sha1-96"] == 1 && [string match $ikeAlgo "aes256-cbc, hmac-sha1, hmac-sha1-96"] ==1 } {
            log.test "aes-cbc-256-sha1-160-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha1-160-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778876
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-256-sha2-256-128"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-sha2-256-128 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-256-sha2-256-128 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-sha256-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-sha256-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/HMAC_SHA2_256_128/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/HMAC_SHA2_256_128," $out] ==1 } {
            log.test "aes-cbc-256-sha2-256-128 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-256-128 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-256-sha2-256-128 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-256-128 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - hmac-sha256-128"] == 1 && [string match $ikeAlgo "aes256-cbc, hmac-sha256, hmac-sha256-128"] ==1 } {
            log.test "aes-cbc-256-sha2-256-128 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-256-128 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778877
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-256-sha2-384-192"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-sha2-384-192 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-256-sha2-384-192 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-sha384-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-sha384-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/HMAC_SHA2_384_192/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/HMAC_SHA2_384_192," $out] ==1 } {
            log.test "aes-cbc-256-sha2-384-192 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-384-192 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA2_384_192/PRF_HMAC_SHA2_384/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-256-sha2-384-192 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-384-192 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - hmac-sha384-192"] == 1 && [string match $ikeAlgo "aes256-cbc, hmac-sha384, hmac-sha384-192"] ==1 } {
            log.test "aes-cbc-256-sha2-384-192 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-384-192 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778878
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-256-sha2-512-256"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-sha2-512-256 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-256-sha2-512-256 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "aes-cbc-256-sha2-512-256 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-512-256 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-256-sha2-512-256 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-512-256 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - hmac-sha512-256"] == 1 && [string match $ikeAlgo "aes256-cbc, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "aes-cbc-256-sha2-512-256 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-sha2-512-256 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778879
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-256-md5-128-96"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-md5-128-96 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-256-md5-128-96 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-md5-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-md5-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/HMAC_MD5_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/HMAC_MD5_96," $out] ==1 } {
            log.test "aes-cbc-256-md5-128-96 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-md5-128-96 ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/HMAC_MD5_96/PRF_HMAC_MD5/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-256-md5-128-96 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-md5-128-96 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - hmac-md5-96"] == 1 && [string match $ikeAlgo "aes256-cbc, hmac-md5, hmac-md5-96"] ==1 } {
            log.test "aes-cbc-256-md5-128-96 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-md5-128-96 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778898
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aes-cbc-256-aes-xcbc"
set descr     "
1.  Change the Certificate type from to aes-cbc-256-aes-xcbc in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aes-cbc-256-aes-xcbc in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256-aesxcbc-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256-aesxcbc-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CBC_256/AES_XCBC_96/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CBC_256/AES_XCBC_96," $out] ==1 } {
            log.test "aes-cbc-256-aes-xcbc ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-aes-xcbc ESP Transform"
        }
        
        if { [string match $certike "AES_CBC_256/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CBC_256/AES_XCBC_96/PRF_AES128_XCBC/MODP_2048" $out] ==1 } {
            log.test "aes-cbc-256-aes-xcbc IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aes-cbc-256-aes-xcbc IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-cbc/256 - xcbc-aes-96"] == 1 && [string match $ikeAlgo "aes256-cbc, xcbcmac-aes, xcbcmac-aes-96"] ==1 } {
            log.test "aes-cbc-256-aes-xcbc IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aes-cbc-256-aes-xcbc IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778880
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aesctr128"
set descr     "
1.  Change the Certificate type from to aesctr128 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aesctr128 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes128ctr-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes128ctr-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CTR_128/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CTR_128/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "aesctr128 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aesctr128 ESP Transform"
        }
        
        if { [string match $certike "AES_CTR_128/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CTR_128/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "aesctr128 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aesctr128 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-ctr/128 - hmac-sha512-256"] == 1 && [string match $ikeAlgo "aes128-ctr, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "aesctr128 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aesctr128 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778886
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aesctr192"
set descr     "
1.  Change the Certificate type from to aesctr192 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aesctr192 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes192ctr-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes192ctr-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CTR_192/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CTR_192/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "aesctr192 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aesctr192 ESP Transform"
        }
        
        if { [string match $certike "AES_CTR_192/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CTR_192/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "aesctr192 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aesctr192 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-ctr/192 - hmac-sha512-256"] == 1 && [string match $ikeAlgo "aes192-ctr, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "aesctr192 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aesctr192 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================  
set id        ePDG:section1:EPDG:C778887:C339696
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/23/2016
set pctComp   100
set summary   "This test verifies ePDG session IKE and ESP Transform as aesctr256"
set descr     "
1.  Change the Certificate type from to aesctr256 in ipsec.conf file on UE
2.  Check the IPSec status and verify the Security certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the Certificate type to aesctr256 in ipsec.conf file on UE" {
        
        ue exec "sed -i '/#*.*ike=/s/.*/\\tike=aes256ctr-sha512-modp2048!/' /etc/ipsec.conf"
        ue exec "sed -i '/#*.*esp=/s/.*/\\tesp=aes256ctr-sha512-modp2048!/' /etc/ipsec.conf"
       
        ue exec "cat /etc/ipsec.conf"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Check the IPSec status and verify the Security certificate on both, StrongSwan and MCC" {
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '1p'"]
        regexp.an {\s*selected proposal: IKE:\s*([A-Z_0-9/:]+)} $out - certike
        
        set out [ue exec "cat /var/log/charon.log | grep -o \"selected proposal:.*\" | sed -n '2p'"]
        regexp.an {\s*selected proposal: ESP:\s*([A-Z_0-9/:]+)} $out - certesp

        set out [ue exec "ipsec statusall"]

        if { [string match $certesp "AES_CTR_256/HMAC_SHA2_512_256/NO_EXT_SEQ"] == 1 && [regexp.an -all "AES_CTR_256/HMAC_SHA2_512_256," $out] ==1 } {
            log.test "aesctr256 ESP Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aesctr256 ESP Transform"
        }
        
        if { [string match $certike "AES_CTR_256/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048"] == 1 && [regexp.an -all "IKE proposal: AES_CTR_256/HMAC_SHA2_512_256/PRF_HMAC_SHA2_512/MODP_2048" $out] ==1 } {
            log.test "aesctr256 IKE Transform negotiated Successfully"
        } else {
            error.an "Failed to negotiate aesctr256 IKE Transform"
        }
        
        set out2 [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*ike-algorithms\s+\"([-0-9A-Z_a-z,\s]+)\"} $out2 - ikeAlgo
        
        set out2 [dut exec "show security history ipsec-negotiations SWU | notab"]
        regexp.an -all {\s*algorithm\s+\"([-0-9/A-Z_a-z,\s]+)\"} $out2 - espAlgo
        
        if { [string match $espAlgo "aes-ctr/256 - hmac-sha512-256"] == 1 && [string match $ikeAlgo "aes256-ctr, hmac-sha512, hmac-sha512-256"] ==1 } {
            log.test "aesctr256 IKE & ESP Transform negotiated Successfully on MCC"
        } else {
            error.an "Failed to negotiate aesctr256 IKE & ESP Transform on MCC"
        }
        
    }    
    
} {
    # Cleanup
    sleep 5
    catch {ue exec "scp /etc/ipsec.conf.antaf /etc/ipsec.conf"}
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C339067:C339068:C339071
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/16/2016
set pctComp   100
set summary   "This test verifies REQS-4549: MAC user location information"
set descr     "
1.  Capture the packets on S2B interface and start the session
2.  Find the Tunnel endpoint IP addresses
3.  Find whether MAC Address is present in Private IEs in Create session Request
4.  Verify if MAC Address of Access Point (Configured on UE) matches with the one in CSR
5.  Decode TCP Packets as DIAMETER and Import EAP Request Packet info
6.  Check that MAC address is not present in the first EAP request to SWm from ePDG
7.  Verify sub pdn-session cli output shows mac address of the decorated NAI"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Capture the packets on S2B interface and start the session" {
        
        ue exec "sed -i '/#*.*leftid=/s/.*/\\tleftid=0456123000000000@1A-2B-3C-4D-5E-6F:nai.epc.mnc123.mcc456.pub.3gppnetwork.org/' /etc/ipsec.conf"
	
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Find whether MAC Address is present in Private IEs in Create session Request" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.addr==$ip1 && ipv6.addr==$ip2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"\" show=\"Private Extension : Starent Networks \(8164\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.ie_type\" showname=\"IE Type: Private Extension} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.enterprise_id\" showname=\"Enterprise ID: Starent Networks \(8164\)} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.proprietary_value\" showname=\"Proprietary value: ([0-9a-zA-Z]+)\"} $packetInfo - mac] == 1 } {             
            log.test "MAC Address is present in Private IEs in Create session Request"
        } else {
            error.an "MAC Address is not present in Private IEs in Create session Request"
        }
        
    }
    
    runStep "Verify if MAC Address of Access Point (Configured on UE) matches with the one in CSR" {
        
        set hexmac [string trimleft $mac 0200]
        set macAdd [binary format H* $hexmac]
        
        if { [string match $macAdd "1A-2B-3C-4D-5E-6F"] == 1 } {
            log.test "MAC Address of Access Point matches with the one in CSR"
        } else {
            error.an "MAC Address of Access Point does not match with the one in CSR"
        }
		
    }
    
    runStep "Decode TCP Packets as DIAMETER and Import EAP Request Packet info" {
        
        tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ swm.serverPort],diameter -Y 'diameter'"
        
        set ip_info [dut exec "show running-config network-context S2B-EPDG loopback-ip SWM-LB-V4 ip-address"]
        
        regexp.an {\s*ip-address\s([0-9.]+)} $ip_info - pgw_swm_lbv4
        
        set out1 [tshark exec "tshark -r /tmp/umakant -d tcp.port==[tb _ swm.serverPort],diameter -Y 'diameter and ip.src==$pgw_swm_lbv4 and ip.dst==[tb _ swm.serverIp]' | grep -e 'Diameter-EAP Request' | sed -n '1p' | awk  '{print \$1}'"]
        set frame_number [ePDG:store_last_line $out1]
        
    }
    
    runStep "Check that MAC address is not present in the first EAP request to SWm from ePDG" {
        
        set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frame_number -T pdml"]
        
        if { [regexp.an "1A-2B-3C-4D-5E-6F" $packetInfo] == 0 && [regexp.an $hexmac $packetInfo] == 0 } {             
            log.test "MAC address is not present in the first EAP request to AAA from ePDG"
        } else {
            error.an "MAC address is present in the first EAP request to AAA from ePDG"
        }
        
    }
    
    runStep "Verify sub pdn-session cli output shows mac address of the decorated NAI" {
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
        if { [regexp.an -lineanchor {^\s*access-point-mac-address\s+([-0-9a-zA-Z]+)$} $out - macid] == 1 && [string match $macid $macAdd] == 1 } {
            log.test "MAC address is correctly displayed on MCC as: $macid"
        } else {
            error.an "MAC address Mismatch ; Expected is: $macAdd ; Displayed is $macid"
        }
        
    }
    
} {
    # Cleanup    
    ue exec "cp /etc/ipsec.conf.antaf /etc/ipsec.conf"
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C341173:C341175:C341176:C341178:C341243
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/30/2016
set pctComp   100
set summary   "This test verifies REQs-3753: Infrastructure support for managing security certificates"
set descr     "
1.  Verify the Certificates on MCC and bring up the Session
2.  Bring up the session and check the Data Path
3.  Delete the Root Certificate on MCC and check if it is also getting deleted from Disk
4.  Install the Root Certificates on MCC using HTTP from remote server and bring up the Session
5.  Delete the ePDG end User Certificates on MCC and check if it is also getting deleted from Disk
6.  Install the ePDG end User Certificates on MCC using HTTP from remote server and bring up the Session
7.  Reload the Certificate and Bring up the session; check the Data Path"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Verify the Certificates on MCC and bring up the Session" {
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:ca1.crt" $keyValues] == 1 } {
            log.test "Found Root Certificate on ePDG"
        } else {
            error.an "Unable to Find Root Certificate on ePDG"
        }
        
        if { [regexp.an "public:epdg1_1.crt" $keyValues] == 1 } {
            log.test "Found End-User Certificate on ePDG"
        } else {
            error.an "Unable to Find End-User Certificate on ePDG"
        }
        
        if { [cmd_out . values.public:epdg1_1.crt.TYPE] == "public" && [cmd_out . values.public:ca1.crt.TYPE] == "public" } {
            log.test "PKI Objects can be identifyied as Public"
        } else {
            error.an "Unable to identify PKI Objects as Public"
        }
    
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Delete the Root Certificate on MCC and check if it is also getting deleted from Disk" {
        
        catch {dut exec "pki remove name ca1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason object removed" $result] == 1 } {
            log.test "Certificate Removing Process Successful"
        } else {
            error.an "Certificate Removing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:ca1.crt" $keyValues] == 0 } {
            log.test "Root Certificate Deleted from ePDG"
        } else {
            error.an "Unable to Delete Root Certificate from ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/ca1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/ca1.crt*"} result2
        
        if { [regexp.an {ls\: cannot access /public/certs/public/ca1\.crt\*\: No such file or directory} $result1] == 1 && [regexp.an {ls\: cannot access /tosdb/certs/public/ca1\.crt\*\: No such file or directory} $result2] == 1 } {
            log.test "Root Certificate Deleted from the Disk"
        } else {
            error.an "Unable to Delete Root Certificate from Disk"
        }
        
    }
    
    runStep "Install the Root Certificates on MCC using HTTP from remote server and bring up the Session" {
        
        catch {dut exec "pki install source http://[tb _ os.host]/sqa/UmakantePDG/Certificates/ca1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason loaded public ca1.crt from http://10.6.1.231/sqa/UmakantePDG/Certificates/ca1.crt" $result] == 1 } {
            log.test "Certificate Installing Process Successful"
        } else {
            error.an "Certificate Installing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:ca1.crt" $keyValues] == 1 } {
            log.test "Root Certificate Successfully installed on ePDG"
        } else {
            error.an "Unable to install Certificate on ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/ca1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/ca1.crt*"} result2
        
        if { [regexp.an {public/certs/public/ca1\.crt} $result1] == 1 && [regexp.an {/tosdb/certs/public/ca1\.crt} $result2] == 1 } {
            log.test "Root Certificate Added to the Disk"
        } else {
            error.an "Unable to Add Root Certificate on the Disk"
        }
    
    }
    
    runStep "Delete the ePDG end User Certificates on MCC and check if it is also getting deleted from Disk" {
        
        catch {dut exec "pki remove name epdg1_1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason object removed" $result] == 1 } {
            log.test "Certificate Removing Process Successful"
        } else {
            error.an "Certificate Removing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:epdg1_1.crt" $keyValues] == 0 } {
            log.test "ePDG end User Certificate Deleted from ePDG"
        } else {
            error.an "Unable to Delete ePDG end User Certificate from ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/epdg1_1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/epdg1_1.crt*"} result2
        
        if { [regexp.an {s\: cannot access /public/certs/public/epdg1_1\.crt\*\: No such file or directory} $result1] == 1 && [regexp.an {ls\: cannot access /tosdb/certs/public/epdg1_1\.crt\*\: No such file or directory} $result2] == 1 } {
            log.test "ePDG end User Certificate Deleted from the Disk"
        } else {
            error.an "Unable to Delete ePDG end User Certificate from Disk"
        }
        
    }
    
    runStep "Install the ePDG end User Certificates on MCC using HTTP from remote server and bring up the Session" {
        
        catch {dut exec "pki install source http://[tb _ os.host]/sqa/UmakantePDG/Certificates/epdg1_1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason loaded public epdg1_1.crt from http://10.6.1.231/sqa/UmakantePDG/Certificates/epdg1_1.crt" $result] == 1 } {
            log.test "Certificate Installing Process Successful"
        } else {
            error.an "Certificate Installing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:epdg1_1.crt" $keyValues] == 1 } {
            log.test "ePDG end User Certificate Successfully installed on ePDG"
        } else {
            error.an "Unable to install Certificate on ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/epdg1_1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/epdg1_1.crt*"} result2
        
        if { [regexp.an {/public/certs/public/epdg1_1\.crt} $result1] == 1 && [regexp.an {/tosdb/certs/public/epdg1_1\.crt} $result2] == 1 } {
            log.test "ePDG end User Certificate Added to the Disk"
        } else {
            error.an "Unable to Add Root Certificate on the Disk"
        }
    
    }
    
    runStep "Reload the Certificate and Bring up the session; check the Data Path" {
        
        catch {dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason" $result] == 1 } {
            log.test "Certificate Reloaded Successfully"
        } else {
            error.an "Certificate Reloading Unsuccessful"
        }
    
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
        
} {
    # Cleanup
    catch {dut exec "pki remove name ca1.crt"}        
    catch {dut exec "pki remove name epdg1_1.crt"}        
    catch {dut exec "pki remove name epdg1_1.prv"}
    catch {dut exec "pki remove name epdg1_1.prv type private"}
    ePDG:checkSessionState
    dut_init    
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C820553:C341177:C341179
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   11/30/2016
set pctComp   100
set summary   "This test verifies REQs-3753: verify pki install source /public/cert1 can get cert from local harddisk path and installs on the ePDG
               	verify show pki objects displaying/identifying private keys"
set descr     "
1.  Verify the Certificates on MCC and bring up the Session
2.  Verify show pki objects displaying/identifying private keys and  show pki objects displaying/identifying private keys
3.  Bring up the session and check the Data Path
4.  Delete the Root Certificate on MCC and check if it is also getting deleted from Disk
5.  Install the Root Certificates on MCC from Disk and bring up the Session
6.  Delete the ePDG end User Certificates on MCC and check if it is also getting deleted from Disk
7.  Install the ePDG end User Certificates on MCC from Disk and bring up the Session
8.  Reload the Certificate and Bring up the session; check the Data Path"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Verify the Certificates on MCC and bring up the Session" {
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:ca1.crt" $keyValues] == 1 } {
            log.test "Found Root Certificate on ePDG"
        } else {
            error.an "Unable to Find Root Certificate on ePDG"
        }
        
        if { [regexp.an "public:epdg1_1.crt" $keyValues] == 1 } {
            log.test "Found End-User Certificate on ePDG"
        } else {
            error.an "Unable to Find End-User Certificate on ePDG"
        }
        
        if { [cmd_out . values.public:epdg1_1.crt.TYPE] == "public" && [cmd_out . values.public:ca1.crt.TYPE] == "public" } {
            log.test "PKI Objects can be identifyied as Public"
        } else {
            error.an "Unable to identify PKI Objects as Public"
        }
        
    }
    
    runStep "Verify show pki objects displaying/identifying private keys " {
    
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
                
        if { [regexp.an "private:epdg1_1.prv" $keyValues] == 1 } {
            log.test "Found Private Key on ePDG"
        } else {
            error.an "Unable to Find Private Key on ePDG"
        }
                
        if { [cmd_out . values.private:epdg1_1.prv.TYPE] == "private" && [cmd_out . values.private:epdg1_1.prv.FORMAT] == "unknown" } {
            log.test "PKI Objects can be identifyied as Private and Unknown because of Password Authentication"
        } else {
            error.an "Unable to identify PKI Objects as Private"
        }
                
        catch {dut exec shell "cd; ls /public/certs/private/epdg1_1.prv*"} result1
        
        if { [regexp.an {public/certs/private/epdg1_1\.prv} $result1] == 1 } {
            log.test "Private key is present in /public/certs/private/"
        } else {
            error.an "Unable to find Private key in /public/certs/private/"
        }
    
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    runStep "Delete the Root Certificate on MCC and check if it is also getting deleted from Disk" {
        
        catch {dut exec "pki remove name ca1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason object removed" $result] == 1 } {
            log.test "Certificate Removing Process Successful"
        } else {
            error.an "Certificate Removing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:ca1.crt" $keyValues] == 0 } {
            log.test "Root Certificate Deleted from ePDG"
        } else {
            error.an "Unable to Delete Root Certificate from ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/ca1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/ca1.crt*"} result2
        
        if { [regexp.an {ls\: cannot access /public/certs/public/ca1\.crt\*\: No such file or directory} $result1] == 1 && [regexp.an {ls\: cannot access /tosdb/certs/public/ca1\.crt\*\: No such file or directory} $result2] == 1 } {
            log.test "Root Certificate Deleted from the Disk"
        } else {
            error.an "Unable to Delete Root Certificate from Disk"
        }
        
    }
    
    runStep "Install the Root Certificates on MCC from Disk and bring up the Session" {
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/ca1.crt /public/" -password [dut . filePassword]    
        
        catch {dut exec "pki install source /public/ca1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason moved public ca1.crt from /public/ca1.crt" $result] == 1 } {
            log.test "Certificate Installing Process Successful"
        } else {
            error.an "Certificate Installing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:ca1.crt" $keyValues] == 1 } {
            log.test "Root Certificate Successfully installed on ePDG"
        } else {
            error.an "Unable to install Certificate on ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/ca1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/ca1.crt*"} result2
        
        if { [regexp.an {public/certs/public/ca1\.crt} $result1] == 1 && [regexp.an {/tosdb/certs/public/ca1\.crt} $result2] == 1 } {
            log.test "Root Certificate Added to the Disk"
        } else {
            error.an "Unable to Add Root Certificate on the Disk"
        }
        
    }
    
    runStep "Delete the ePDG end User Certificates on MCC and check if it is also getting deleted from Disk" {
        
        catch {dut exec "pki remove name epdg1_1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason object removed" $result] == 1 } {
            log.test "Certificate Removing Process Successful"
        } else {
            error.an "Certificate Removing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:epdg1_1.crt" $keyValues] == 0 } {
            log.test "ePDG end User Certificate Deleted from ePDG"
        } else {
            error.an "Unable to Delete ePDG end User Certificate from ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/epdg1_1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/epdg1_1.crt*"} result2
        
        if { [regexp.an {ls\: cannot access /public/certs/public/epdg1_1\.crt\*\: No such file or directory} $result1] == 1 && [regexp.an {ls\: cannot access /tosdb/certs/public/epdg1_1\.crt\*\: No such file or directory} $result2] == 1 } {
            log.test "ePDG end User Certificate Deleted from the Disk"
        } else {
            error.an "Unable to Delete ePDG end User Certificate from Disk"
        }
        
    }
    
    runStep "Install the ePDG end User Certificates on MCC from Disk and bring up the Session" {
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1.crt /public/" -password [dut . filePassword]    
        
        catch {dut exec "pki install source /public/epdg1_1.crt"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason moved public epdg1_1.crt from /public/epdg1_1.crt" $result] == 1 } {
            log.test "Certificate Installing Process Successful"
        } else {
            error.an "Certificate Installing Process Unsuccessful"
        }
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:epdg1_1.crt" $keyValues] == 1 } {
            log.test "ePDG end User Certificate Successfully installed on ePDG"
        } else {
            error.an "Unable to install Certificate on ePDG"
        }
        
        catch {dut exec shell "cd; ls /public/certs/public/epdg1_1.crt*"} result1
        catch {dut exec shell "cd; ls /tosdb/certs/public/epdg1_1.crt*"} result2
        
        if { [regexp.an {/public/certs/public/epdg1_1\.crt} $result1] == 1 && [regexp.an {/tosdb/certs/public/epdg1_1\.crt} $result2] == 1 } {
            log.test "ePDG end User Certificate Added to the Disk"
        } else {
            error.an "Unable to Add Root Certificate on the Disk"
        }
    
    }
    
    runStep "Reload the Certificate and Bring up the session; check the Data Path" {
        
        catch {dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"} result
        
        if { [regexp.an "result success" $result] == 1 && [regexp.an "reason" $result] == 1 } {
            log.test "Certificate Reloaded Successfully"
        } else {
            error.an "Certificate Reloading Unsuccessful"
        }
    
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
         
    }
    
    
} {
    # Cleanup
    catch { dut exec shell "rm /public/epdg1_1.crt" }
    catch { dut exec shell "rm /public/ca1.crt" }
    dut_init
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C281148:C281144
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/1/2016
set pctComp   100
set summary   "Create one root, one intermediate CA with one end-user, bring up session, replace end-user-certificate &&
               Replace the expiring end-user certificate, verify session setup without rebooting or bouncing admin state during certifiate replacement"
set descr     "
1.  Change the file names of Root and End User Cerstificates and add Intermediate Certificate
2.  Bring up the session and check the Data Path
3.  Verify the End User 1 and Intermediate Certificate
4.  Delete the 1st End User Certificates and add 2nd one
5.  Bring up the session and check the Data Path
6.  Verify the End User 1 and Intermediate Certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the file names of Root and End User Cerstificates and add Intermediate Certificate" {
        
        catch {dut exec "pki remove name epdg1_1.crt"}        
        catch {dut exec "pki remove name epdg1_1.prv"}
        catch {dut exec "pki remove name epdg1_1.prv type private"}
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/intermediate1_1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_1.prv /public/certs/private/" -password [dut . filePassword]
       
        dut exec config "no security authentication pki-certificate-management EPDG-ACCESS-1"        
        dut exec config "commit"
        dut exec config "security authentication pki-certificate-management EPDG-ACCESS-1 network-context SWU file-name epdg1_1_1 file-type pem certificate-type local key-passphrase Chaitrali"        
        dut exec config "security authentication pki-certificate-management INTERMEDIATE-CERT certificate-type intermediate-trust file-name intermediate1_1 file-type pem authentication-domain EPDG-AUTH-DOMAIN network-context SWU"
        dut exec config "commit"
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"        
        dut exec "security authentication pki-certificate-management INTERMEDIATE-CERT reload"
                
        dut exec config "network-context SWU security disabled"
        dut exec config "commit"    
        dut exec config "network-context SWU security enabled"
        dut exec config "commit"
        sleep 90
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:intermediate1_1.crt" $keyValues] == 1 } {
            log.test "Found Intermediate Certificate on ePDG"
        } else {
            error.an "Unable to Find Intermediate Certificate on ePDG"
        }
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the End User 1 and Intermediate Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg1_1_1@affirmednetworks.com,id-at-commonName=ePDG - 1_1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=intermediate_ca1_1@affirmednetworks.com,id-at-commonName=Intermediate CA - 1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stat\"} $packetInfo] == 1 } {
            log.test "End User 1 and Intermediate Certificate Found"
        } else {
            error.an "Unable to find End User 1 and Intermediate Certificate"
        }
        
    }
    
    runStep "Delete the 1st End User Certificates and add 2nd one" {
        
        ePDG:clear_tshark_data
        ePDG:clear_ipsec_decrypt_data
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_2.crt /public/certs/public/epdg1_1_1.crt" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_2.prv /public/certs/private/epdg1_1_1.prv" -password [dut . filePassword]
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"
        sleep 30
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the End User 2 and Intermediate Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg1_1_2@affirmednetworks.com,id-at-commonName=ePDG - 1_1_2,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=intermediate_ca1_1@affirmednetworks.com,id-at-commonName=Intermediate CA - 1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stat\"} $packetInfo] == 1 } {
            log.test "End User 2 and Intermediate Certificate Found"
        } else {
            error.an "Unable to find End User 2 and Intermediate Certificate"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data    
    dut_init        
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C281149:C281145
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/2/2016
set pctComp   100
set summary   "Create and update the intermediate CA and the end-users, bring up session &&
               Replace the expiring intermediate certificate and end-user certificate, verify session setup without rebooting or bouncing admin state during certifiate replacement"
set descr     "
1.  Change the file names of Root and End User Cerstificates and add Intermediate Certificate
2.  Bring up the session and check the Data Path
3.  Verify the End User 1 and Intermediate - 1 Certificate
4.  Delete the 1st End User Certificates and Intermediate - 1 and add 2nd one
5.  Bring up the session and check the Data Path
6.  Verify the End User 1 and Intermediate - 2 Certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the file names of Root and End User Cerstificates and add Intermediate Certificate" {
        
        catch {dut exec "pki remove name epdg1_1.crt"}        
        catch {dut exec "pki remove name epdg1_1.prv"}
        catch {dut exec "pki remove name epdg1_1.prv type private"}
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/intermediate1_1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_1.prv /public/certs/private/" -password [dut . filePassword]
       
        dut exec config "no security authentication pki-certificate-management EPDG-ACCESS-1"        
        dut exec config "commit"
        dut exec config "security authentication pki-certificate-management EPDG-ACCESS-1 network-context SWU file-name epdg1_1_1 file-type pem certificate-type local key-passphrase Chaitrali"        
        dut exec config "security authentication pki-certificate-management INTERMEDIATE-CERT certificate-type intermediate-trust file-name intermediate1_1 file-type pem authentication-domain EPDG-AUTH-DOMAIN network-context SWU"
        dut exec config "commit"
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"        
        dut exec "security authentication pki-certificate-management INTERMEDIATE-CERT reload"
                
        dut exec config "network-context SWU security disabled"
        dut exec config "commit"    
        dut exec config "network-context SWU security enabled"
        dut exec config "commit"
        sleep 90
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:intermediate1_1.crt" $keyValues] == 1 } {
            log.test "Found Intermediate Certificate on ePDG"
        } else {
            error.an "Unable to Find Intermediate Certificate on ePDG"
        }
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the End User 1 and Intermediate Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg1_1_1@affirmednetworks.com,id-at-commonName=ePDG - 1_1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=intermediate_ca1_1@affirmednetworks.com,id-at-commonName=Intermediate CA - 1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stat\"} $packetInfo] == 1 } {
            log.test "End User 1 and Intermediate Certificate Found"
        } else {
            error.an "Unable to find End User 1 and Intermediate Certificate"
        }
        
    }
    
    runStep "Delete the 1st End User Certificate and Intermediate Certificate and add 2nd one" {
        
        ePDG:clear_tshark_data
        ePDG:clear_ipsec_decrypt_data
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_2_1.crt /public/certs/public/epdg1_1_1.crt" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_2_1.prv /public/certs/private/epdg1_1_1.prv" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/intermediate1_2.crt /public/certs/public/intermediate1_1.crt" -password [dut . filePassword]
                
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"        
        dut exec "security authentication pki-certificate-management INTERMEDIATE-CERT reload"
        sleep 30
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
         
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the End User 2 and Intermediate - 2 Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg1_2_1@affirmednetworks.com,id-at-commonName=ePDG - 1_2_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=intermediate_ca1_2@affirmednetworks.com,id-at-commonName=Intermediate CA - 1_2,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stat\"} $packetInfo] == 1 } {
            log.test "End User 2 and Intermediate - 2 Certificate Found"
        } else {
            error.an "Unable to find End User 2 and Intermediate Certificate"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data    
    dut_init        
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C308238
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/2/2016
set pctComp   100
set summary   "Verify call flow for self-signed certificates"
set descr     "
1.  Change the file names of Self-signed and End User Cerstificates
2.  Bring up the session and check the Data Path
3.  Verify the Self-signed Certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the file names of Self-signed and End User Cerstificates" {
        
        catch { dut exec shell "rm /public/certs/public/*" }
        catch { dut exec shell "rm /public/certs/private/*" }
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"
        dut exec "security authentication pki-certificate-management ROOT-CERT reload"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1.prv /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1.prv /public/certs/private/" -password [dut . filePassword]
       
        dut exec config "no security authentication pki-certificate-management ROOT-CERT"
        dut exec config "no security authentication pki-certificate-management EPDG-ACCESS-1"        
        dut exec config "commit"        
        
        dut exec config "security authentication pki-certificate-management EPDG-ACCESS-1 network-context SWU file-name epdg1 file-type pem certificate-type local key-passphrase Chaitrali"        
        dut exec config "security authentication pki-certificate-management ROOT-CERT certificate-type ca-trust file-name epdg1 file-type pem authentication-domain EPDG-AUTH-DOMAIN network-context SWU"
        dut exec config "commit"
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"
        dut exec "security authentication pki-certificate-management ROOT-CERT reload"
        
        dut exec config "network-context SWU security disabled"
        dut exec config "commit"    
        dut exec config "network-context SWU security enabled"
        dut exec config "commit"
        sleep 90
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:epdg1.crt" $keyValues] == 1 && [regexp.an "public:epdg1.prv" $keyValues] == 1 && [regexp.an "private:epdg1.prv" $keyValues] == 1 } {
            log.test "Found Self-signed Certificate on ePDG"
        } else {
            error.an "Unable to Find Self-signed Certificate on ePDG"
        }
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the Self-signed Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]

        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg1@affirmednetworks.com,id-at-commonName=ePDG - 1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA,id-at-c\"} $packetInfo] == 1 } {
            log.test "Self-signed Certificate Found"
        } else {
            error.an "Unable to find Self-signed Certificate"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data    
    dut_init        
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C281146
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/30/2016
set pctComp   100
set summary   "Replace the expiring root,intermediate and end-user certificate, verify session setup without rebooting or bouncing admin state during certifiate replacement"
set descr     "
1.  Change the file names of Root and End User Cerstificates and add Intermediate Certificate
2.  Bring up the session and check the Data Path
3.  Verify the End User 1 Root - 1 and Intermediate Certificate
4.  Delete the 1st End User Certificate, Intermediate Certificate, Root Certificate and add 2nd ones
5.  Bring up the session and check the Data Path
6.  Verify the End User 2 and Intermediate - 2  and Root -2 Certificate"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Change the file names of Root and End User Cerstificates and add Intermediate Certificate" {
        
        catch {dut exec "pki remove name epdg1_1.crt"}        
        catch {dut exec "pki remove name epdg1_1.prv"}
        catch {dut exec "pki remove name epdg1_1.prv type private"}
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/intermediate1_1.crt /public/certs/public/" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg1_1_1.prv /public/certs/private/" -password [dut . filePassword]
       
        dut exec config "no security authentication pki-certificate-management EPDG-ACCESS-1"        
        dut exec config "commit"
        dut exec config "security authentication pki-certificate-management EPDG-ACCESS-1 network-context SWU file-name epdg1_1_1 file-type pem certificate-type local key-passphrase Chaitrali"        
        dut exec config "security authentication pki-certificate-management INTERMEDIATE-CERT certificate-type intermediate-trust file-name intermediate1_1 file-type pem authentication-domain EPDG-AUTH-DOMAIN network-context SWU"
        dut exec config "commit"
        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"        
        dut exec "security authentication pki-certificate-management INTERMEDIATE-CERT reload"
                
        dut exec config "network-context SWU security disabled"
        dut exec config "commit"    
        dut exec config "network-context SWU security enabled"
        dut exec config "commit"
        sleep 90
        
        dut exec "show pki objects"
        
        set keyValues [cmd_out . key-values]
        
        if { [regexp.an "public:intermediate1_1.crt" $keyValues] == 1 } {
            log.test "Found Intermediate Certificate on ePDG"
        } else {
            error.an "Unable to Find Intermediate Certificate on ePDG"
        }
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the End User 1 Root - 1 and Intermediate Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg1_1_1@affirmednetworks.com,id-at-commonName=ePDG - 1_1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=intermediate_ca1_1@affirmednetworks.com,id-at-commonName=Intermediate CA - 1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stat\"} $packetInfo] == 1 } {
            log.test "End User 1 and Intermediate Certificate Found"
        } else {
            error.an "Unable to find End User 1 and Intermediate Certificate"
        }
        
    }
    
    runStep "Delete the 1st End User Certificate, Intermediate Certificate, Root Certificate and add 2nd ones" {
        
        ePDG:clear_tshark_data
        ePDG:clear_ipsec_decrypt_data
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"
        
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/ca2.crt /public/certs/public/ca1.crt" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg2_1_1.crt /public/certs/public/epdg1_1_1.crt" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/intermediate2_1.crt /public/certs/public/intermediate1_1.crt" -password [dut . filePassword]
        dut scp "[dut . fileUser]@[dut . fileServer]:$::env(ANTAF_DIR)/suites/ePDG/setup/dut/Certificates/epdg2_1_1.prv /public/certs/private/epdg1_1_1.prv" -password [dut . filePassword]
        
        dut exec "security authentication pki-certificate-management ROOT-CERT reload"        
        dut exec "security authentication pki-certificate-management EPDG-ACCESS-1 reload"        
        dut exec "security authentication pki-certificate-management INTERMEDIATE-CERT reload"
        sleep 50
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
         
        catch { dut exec shell "scp /var/log/eventlog/umakant* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/umakant* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/umakant*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/umakant*" }
         
    }
    
    runStep "Verify the End User 2 and Intermediate - 2  and Root -2 Certificate" {
        
        dut exec "show security statistics tunnel SWU"
        set ip1 [cmd_out . values.SWU.REMOTEADDRESS]
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'EAP' | grep 'Request, UMTS Authentication and Key Agreement EAP (EAP-AKA)' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=epdg2_1_1@affirmednetworks.com,id-at-commonName=ePDG - 2_1_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stateOrProvinceName=MA\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.cert.data\" showname=\"Certificate Data \(pkcs-9-at-emailAddress=intermediate_ca2_1@affirmednetworks.com,id-at-commonName=Intermediate CA - 2_1,id-at-organizationalUnitName=SQA - Umakant,id-at-organizationName=Affirmed Networks,id-at-localityName=Acton,id-at-stat\"} $packetInfo] == 1 } {
            log.test "End User 2 and Intermediate - 2 Certificate Found"
        } else {
            error.an "Unable to find End User 2 and Intermediate Certificate"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data    
    dut_init        
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C212185:C212186:C226620
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/7/2016
set pctComp   100
set summary   "REQ 3992 - verify ePDG's create session request's EAP-GTC parameters"
set descr     "
1.  Enable the EAP-GTC Authentication on epdg-tunnel & Start the Packet Capture
2.  Bring up the session and check the Data Path
3.  Stop & import the PCAPs and decrypy IPSEc Packets
4.  Verify that the ePDG is Supporting the Multiple Authentications
5.  Verify EAP-GTC Parameters in Create session Request"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Enable the EAP-GTC Authentication on epdg-tunnel & Start the Packet Capture" {
        
        dut exec config "security policy tunnel SWU epdg-tunnel second-authentication-domain EPDG-AUTH-DOMAIN-2"
        dut exec config "commit"
        
        dut exec config "workflow control-profile CONTROL-PROFILE-PGW ; no default-s6b-interface"
        dut exec config "commit"
        
        dut exec "network-context SWU ip-interface SWU-5-1 startcapture count 10000 duration 600 file-name SWU-5-1"
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 30000 duration 1200 file-name umakant"
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        ue exec "ipsec restart"
        ue closeCli
        ue initCli -4 true
        set out1 [ue exec "ipsec up epdg-gtc" -exitCode 0]

        if { [regexp.an "connection 'epdg-gtc' established successfully" $out1] } {
            log.test "UE reports: connection 'epdg-gtc' established successfully"
        } else {
            error.an "Failed to establish 'epdg-gtc' connection"
        }

        if { [regexp.an {installing new virtual IP ([0-9.]+)\sinstalling new virtual IP ([0-9:a-z]+)} $out1 - ueIpv4 ueIpv6] } {
            log.test "Found new virtual IPv4 and IPv6: $ueIpv4 $ueIpv6"
        } else {
            error.an "Failed to retrieve new virtual IPs"
        }

        dut exec "show subscriber summary gateway-type epdg"

        if { ![string is integer -strict [set id_ [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { ![string is integer -strict [set pgwid [lindex [cmd_out . key-values] 0]]] } {
            error.an "Expected one pgw session"
        } else {
            log.test "Found pgw session with id: $pgwid"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        if { [regexp.an -lineanchor {^\s*ue-v4-ip-address\s+([0-9.]+)$} $out - ueIp4] } {
            log.test "Found ue-v4-ip-address: $ueIp4"
        } else {
            error.an "Failed to retrieve ue-v4-ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*ue-v6-ip-address\s+([0-9:a-z]+)$} $out - ueIp6] } {
            log.test "Found ue-v6-ip-address: $ueIp6"
        } else {
            error.an "Failed to retrieve ue-v6-ip-address"
        }

        if { $ueIpv4 == $ueIp4 && $ueIpv6 == $ueIp6 } {
            log.test "UE IP addresses as reported by UE and MCC match"
        } else {
            error "UE IP addresses as reported by UE ($ueIpv4 & $ueIpv6) and MCC ($ueIp4 & $ueIp6) do not match"
        }

        set out [ue exec "ip -o addr show up primary scope global"]

        if { [regexp "$ueIp4" $out] && [regexp "$ueIp6" $out]  } {
            log.test "IP address reported by UE"
        } else {
            error.an "UE does not report the new IP ($ueIp4 and $ueIp6) as active"
        }
        
        ePDG:ue_ping_os $ueIp4
        ePDG:ue_ping_os2 $ueIp4
        ePDG:ue_tcp_os $ueIp4
        ePDG:ue_ping6_os $ueIp6
        ePDG:ue_ping6_os2 $ueIp6
        ePDG:ue_tcp6_os $ueIp6
    
    }
    
    runStep "Stop & import the PCAPs and decrypy IPSEc Packets" {
        
        dut exec "network-context SWU ip-interface SWU-5-1 stopcapture"
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        ePDG:decrypt_ipsec
        
        catch { dut exec shell "scp /var/log/eventlog/SWU-5-1* /var/log/pcapFiles/" }
        set numberFiles [expr [dut exec shell "cd; ls /var/log/eventlog/SWU-5-1* | wc -l"] - 1]
        dut exec shell "cd; ls /var/log/eventlog/SWU-5-1*"
        dut scp " [lindex [cmd_out . full] $numberFiles] [tb _ ue.user]@[tb _ ue.host]:/usr/share/wireshark/umakant" -password [tb _ ue.password] -timeout 60
        catch { dut exec shell "rm /var/log/eventlog/SWU-5-1*" }
        
        import_tshark_file
         
    }
    
    runStep "Verify that the ePDG is Supporting the Multiple Authentications" {
                
        set ikeHistory [dut exec "show security history ike-negotiations SWU | notab"]
        regexp.an -all {\s*remote-address\s+([0-9.A-Z:a-z]+)} $ikeHistory - ip1
        
        set security_status [ue exec "ip xfrm state"]
        
        if { [regexp.an {src\s([0-9:a-z]+)\sdst\s([0-9:a-z]+)} $security_status - garbage ip2] == 0 } {
            regexp.an {src\s([0-9.]+)\sdst\s([0-9.]+)} $security_status - garbage ip2
        }
        
        ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp'"
        set out1 [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'isakmp and ip.src==$ip2 and ip.dst==$ip1' |  grep 'IKE_SA_INIT' | grep 'Responder Response' | sed -n '1p' | awk '{print \$1}'"]
        regexp.an -all -lineanchor {\s([0-9]+)} $out1 - frameNumber
        
        set packetInfo [ue exec "tshark -r /usr/share/wireshark/umakant -Y 'frame.number==$frameNumber' -T pdml"]
        
        if { [regexp.an {<field name=\"isakmp.typepayload\" showname=\"Type Payload: Notify \(([0-9]+)\) - MULTIPLE_AUTH_SUPPORTED\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"isakmp.notify.msgtype\" showname=\"Notify Message Type: MULTIPLE_AUTH_SUPPORTED} $packetInfo] == 1 } {
            log.test "ePDG is Supporting the Multiple Authentications"
        } else {
            error.an "ePDG is not Supporting the Multiple Authentications"
        }
        
    }
    
    runStep "Verify EAP-GTC Parameters in Create session Request" {
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep -e \"Create Session Request\" | awk  '{print \$1}' | sed -n '1p'"]
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gsm_a.gm.sm.pco_pid\" showname=\"Protocol or Container ID: Password Authentication Protocol \(0xc023\)\"} $packetInfo] == 1 &&
             [regexp.an {<proto name=\"pap\" showname=\"PPP Password Authentication Protocol\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"pap.code\" showname=\"Code: Authenticate-Request \(1\)} $packetInfo] == 1 &&
             [regexp.an {<field name=\"pap.peer_id\" showname=\"Peer-ID: ([-0-9._@a-zA-Z]+)\"} $packetInfo - imsi] == 1 &&
             [regexp.an {<field name=\"pap.password\" showname=\"Password: ([-0-9._@a-zA-Z]+)\"} $packetInfo - password] == 1 } {
            log.test "Found EAP-GTC Parameters in Create session Request"
        } else {
            error.an "Unable to find EAP-GTC Parameters in Create session Request"
        }
        
        if { [string match $imsi [ue . imsi_nai]] == 1 && [string match $password "UmakantKulkarni"] == 1 } {
            log.test "EAP-GTC Parameters Verified in Create session Request"
        } else {
            error.an "Unable to verify EAP-GTC Parameters in Create session Request"
        }
        
    }
    
} {
    # Cleanup
    dut exec config "security policy tunnel SWU epdg-tunnel ; no second-authentication-domain"
    dut exec config "commit"
    dut exec config "workflow control-profile CONTROL-PROFILE-PGW default-s6b-interface S6b_INTF"
    dut exec config "commit"
    ePDG:clear_tshark_data
    ePDG:clear_ipsec_decrypt_data
    ePDG:checkSessionState
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778963:C778964:C778965
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/8/2016
set pctComp   100
set summary   "Test verifies T3 Timer and N3 Counters on ePDG"
set descr     "
1.  Verify the N-3 Count Range
2.  Verify the T-3 Timer Range"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Verify the N-3 Timer Range" {
        
        for {set i 1} {$i < 6} {incr i} {
            
            if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface n3-count $i"] == 1 } {
                log.test "N-3 Count can be set as $i"  
            } else {
                error.an "Unable to set N-3 Count as $i"
            }
            
        }            
        
       if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface n3-count 0"] == 0 &&
            [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface n3-count 6"] == 0 } {
            log.test "N-3 Count Range Verified"  
        } else {
            error.an "Unable to Verify the N-3 Count Range"
        }
        
    }
    
    runStep "Verify the T-3 Timer Range" {
       
       if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface t3-timeout 99"] == 0 &&
            [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface t3-timeout 100"] == 1 &&
            [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface t3-timeout 100000"] == 1 &&
            [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface t3-timeout 3600000"] == 1 &&
            [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-interface t3-timeout 3600001"] == 0} {
            log.test "T-3 Timer Range Verified"  
        } else {
            error.an "Unable to Verify the T-3 Timer Range"
        }
        
    }
    
} {
    # Cleanup    
    dut exec config "zone default gateway epdg EPDG-1 s2b-interface t3-timeout 3000"
    dut exec config "commit"
    dut exec config "zone default gateway epdg EPDG-1 s2b-interface n3-count 2"
    dut exec config "commit"
    ePDG:mcc_crash_checkup
}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
    if { $i ==0 } {
        set id        ePDG:section1:EPDG:C778954
        set summary   "Support for configuring GTP-C & GTP-U on only v4 ePDG loopback address ; Check is session is successful"
    } else {
        set id        ePDG:section1:EPDG:C778968
        set summary   "Configure only v4 loopbacks on gtpc, reboot the CSM and verify the call-flow"
    }
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/8/2016
set pctComp   100
set descr     "
1.  Set ePDG & PGW GTP-c Loopbacks as V4 Only
2.  Set ePDG & PGW GTP-U Loopbacks as V4 Only
3.  Bring up the session and check the Data Path
4.  Get the Source and Destination IP addresses of the GTP-C messages
5.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
6.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages
7.  Find out the Ping Packets from UE to OS to verify IPv4 data path on S2B interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Set ePDG & PGW GTP-C Loopbacks as V4 Only" {
        
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 ; commit"            
            dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
            log.test "S2B-EPDG GTP-C ON V4 Only"
        } else {
            error.an "Unable to set S2B-EPDG GTP-C as V4 Only Loopback IP"
        }
            
        if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4"] == 1 } {            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
            dut exec config "no zone default gateway pgw PGW-1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
            log.test "S2B-PGW GTP-C ON V4 Only"
        } else {
            error.an "Unable to set S2B-PGW GTP-C as V4 Only Loopback IP"
        }        
       
    }
    
    runStep "Set ePDG & PGW GTP-U Loopbacks as V4 Only" {
        
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 gtpu-loopback-list S2B-EPDG-LB-V4"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 gtpu-loopback-list S2B-EPDG-LB-V4 ; commit"            
            log.test "S2B-EPDG GTP-U ON V4 Only"
        } else {
            error.an "Unable to set S2B-EPDG GTP-U as V4 Only Loopback IP"
        }
        
       if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpu-loopback-list PGW-LB-V4"] == 1 } {            
            dut exec config "zone default gateway pgw PGW-1 gtpu-loopback-list PGW-LB-V4 ; commit"            
            log.test "S2B-PGW GTP-U ON V4 Only"
        } else {
            error.an "Unable to set S2B-PGW GTP-U as V4 Only Loopback IP"
        }
        
        dut exec config "zone default gateway sgw SGW-1 admin-state disabled ; commit"        
        dut exec config "no zone default gateway sgw ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V4 ; commit"        
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        if { $i == 0 } {
            puts "Test without rebooting the CSM"
        } else {
            puts "Reboot the the CSM"
            dut exec "cluster [tb _ dut.chassisNumber] node 1 reboot"        
            sleep 210        
            dut_init    
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
         
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_pgw
        
        if { [string match $ip1 $ipv4_epdg] == 1 && [string match $ip2 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet for CSRs"
        } else {
            error.an "Tunnel Endpoint IPv4 addresses do not match with the Source and Dest. IPv4 addresses for GTP-C packet for CSRs"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Bearer Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for Bearer request and response"
        }
        
        if { [string match $ip2 $ipv4_epdg] == 1 && [string match $ip1 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet for CBRs"
        } else {
            error.an "Tunnel Endpoint IPv4 addresses do not match with the Source and Dest. IPv4 addresses for GTP-C packet for CBRs"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv4 data path on S2B interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
        tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmp'"
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipv4_epdg and ip.addr==$ipv4_pgw and icmp' | wc -l"]
        regexp.an -all -lineanchor {\s*([0-9]+)} $out - ping_packet_count
        
        if { $ping_packet_count == 20 } {
            log.test "Data path between ePDG and PGW on S2B is IPv4"
        } else {
            error.an "Data path between ePDG and PGW is not IPv4 on S2B Interface"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V4 ip-address [tb _ dut.SGW-LB-V4] gtp-u yes ; commit"    
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address [tb _ dut.SGW-LB-V6] gtp-u yes ; commit"    
    dut exec config "zone default gateway sgw SGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW s1u-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6"
    dut exec config "zone default gateway sgw SGW-1 s5-s8-interface-network-context S2B-PGW s5-s8-gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn.epdg-access-pi.net ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn2.epdg-access-pi.net ; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}
}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
    if { $i ==0 } {
        set id        ePDG:section1:EPDG:C778955
        set summary   "Support for configuring GTP-C & GTP-U on only v6 ePDG loopback address ; Check is session is successful"
    } else {
        set id        ePDG:section1:EPDG:C778969
        set summary   "Configure only v6 loopbacks on gtpc, reboot the CSM and verify the call-flow"
    }
set id        ePDG:section1:EPDG:C778955
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/9/2016
set pctComp   100
set descr     "
1.  Set ePDG & PGW GTP-c Loopbacks as V6 Only
2.  Set ePDG & PGW GTP-U Loopbacks as V6 Only
3.  Bring up the session and check the Data Path
4.  Get the Source and Destination IP addresses of the GTP-C messages
5.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
6.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages
7.  Find out the Ping Packets from UE to OS to verify IPv6 data path on S2B interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Set ePDG & PGW GTP-C Loopbacks as V6 Only" {                
          
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ; commit"            
            dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
            log.test "S2B-EPDG GTP-C ON V6 Only"
        } else {
            error.an "Unable to set S2B-EPDG GTP-C as V6 Only Loopback IP"
        }
            
        if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6"] == 1 } {            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
            dut exec config "no zone default gateway pgw PGW-1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
            log.test "S2B-PGW GTP-C ON V6 Only"
        } else {
            error.an "Unable to set S2B-PGW GTP-C as V6 Only Loopback IP"
        }        
       
    }
    
    runStep "Set ePDG & PGW GTP-U Loopbacks as V4 Only" {
        
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 gtpu-loopback-list S2B-EPDG-LB-V6"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 gtpu-loopback-list S2B-EPDG-LB-V6 ; commit"            
            log.test "S2B-EPDG GTP-U ON V6 Only"
        } else {
            error.an "Unable to set S2B-EPDG GTP-U as V6 Only Loopback IP"
        }
        
       if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpu-loopback-list PGW-LB-V6"] == 1 } {            
            dut exec config "zone default gateway pgw PGW-1 gtpu-loopback-list PGW-LB-V6 ; commit"            
            log.test "S2B-PGW GTP-U ON V6 Only"
        } else {
            error.an "Unable to set S2B-PGW GTP-U as V6 Only Loopback IP"
        }
        
        dut exec config "zone default gateway sgw SGW-1 admin-state disabled ; commit"        
        dut exec config "no zone default gateway sgw ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V4 ; commit" 
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        if { $i == 0 } {
            puts "Test without rebooting the CSM"
        } else {
            puts "Reboot the the CSM"
            dut exec "cluster [tb _ dut.chassisNumber] node 1 reboot"        
            sleep 210        
            dut_init    
        }
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
         
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_pgw
        
        if { [string match $ip1 $ipv6_epdg] == 1 && [string match $ip2 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet for CSRs"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet for CSRs"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Bearer Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for Bearer request and response"
        }
        
        if { [string match $ip2 $ipv6_epdg] == 1 && [string match $ip1 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet for CBRs"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet for CBRs"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify IPv6 data path on S2B interface" {
       
        set out [tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipv6_epdg and ipv6.addr==$ipv6_pgw and icmpv6' | grep 'request'  | wc -l"]
        regexp.an -all -lineanchor {\s*([0-9]+)} $out - ping_packet_count
        
        if { $ping_packet_count == 20 } {
            log.test "Data path between ePDG and PGW on S2B is IPv6"
        } else {
            error.an "Data path between ePDG and PGW is not IPv6 on S2B Interface"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V4 ip-address [tb _ dut.SGW-LB-V4] gtp-u yes ; commit"    
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address [tb _ dut.SGW-LB-V6] gtp-u yes ; commit"    
    dut exec config "zone default gateway sgw SGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW s1u-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6"
    dut exec config "zone default gateway sgw SGW-1 s5-s8-interface-network-context S2B-PGW s5-s8-gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn.epdg-access-pi.net ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn2.epdg-access-pi.net ; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}
}

# ==============================================================
set id        ePDG:section1:EPDG:C778956
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/9/2016
set pctComp   100
set summary   "	Support for configuring GTP-C on v4v6 ePDG loopback address ; Primary - v4 Secondary - v6 ; Check is session is successful"
set descr     "
1.  Set ePDG & PGW GTP-c Loopbacks as V4V6
3.  Bring up the session and check the Data Path
4.  Get the Source and Destination IP addresses of the GTP-C messages
5.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
6.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages
7.  Find out the Ping Packets from UE to OS to verify  data path on S2B interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Set ePDG & PGW GTP-C Loopbacks as V4V6 Only" {
        
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V6"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"            
            dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
            log.test "S2B-EPDG GTP-C ON V4V6"
        } else {
            error.an "Unable to set S2B-EPDG GTP-C as V4V6 Loopback IP"
        }
            
        if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4 secondary-loopback-ip PGW-LB-V6"] == 1 } {            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
            dut exec config "no zone default gateway pgw PGW-1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4 secondary-loopback-ip PGW-LB-V6 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
            log.test "S2B-PGW GTP-C ON V4V6"
        } else {
            error.an "Unable to set S2B-PGW GTP-C as V4V6 Loopback IP"
        }
        
        dut exec config "zone default gateway sgw SGW-1 admin-state disabled ; commit"        
        dut exec config "no zone default gateway sgw ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V4 ; commit" 
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
         
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_pgw
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_pgw
        
        if { [string match $ip1 $ipv4_epdg] == 1 && [string match $ip2 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet CSRs"
        } elseif { [string match $ip1 $ipv6_epdg] == 1 && [string match $ip2 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet CSRs"
        } else {
            error.an "Tunnel Endpoint addresses do not match with the Source and Dest. addresses for GTP-C packet CSRs"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Bearer Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for Bearer request and response"
        }
        
        if { [string match $ip2 $ipv4_epdg] == 1 && [string match $ip1 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet CBRs"
        } elseif { [string match $ip2 $ipv6_epdg] == 1 && [string match $ip1 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet CBRs"
        } else {
            error.an "Tunnel Endpoint addresses do not match with the Source and Dest. addresses for GTP-C packet CBRs"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify GTP-ICMP data path on S2B interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
        tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmpv6'"
        
        if { [tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipv4_epdg and ip.addr==$ipv4_pgw and icmpv6' | grep 'request'  | wc -l"] != 0 } {
            set out [tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipv4_epdg and ip.addr==$ipv4_pgw and icmpv6' | grep 'request'  | wc -l"]
            regexp.an -all -lineanchor {\s*([0-9]+)} $out - ping_packet_count
        } else {
            set out [tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipv6_epdg and ipv6.addr==$ipv6_pgw and icmpv6' | grep 'request'  | wc -l"]
            regexp.an -all -lineanchor {\s*([0-9]+)} $out - ping_packet_count
        }
        
        if { $ping_packet_count == 20 } {
            log.test "Data packets between ePDG and PGW on S2B are passing through GTP Tunnel"
        } else {
            error.an "Data packets between ePDG and PGW on S2B are not passing through GTP Tunnel"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V4 ip-address [tb _ dut.SGW-LB-V4] gtp-u yes ; commit"    
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address [tb _ dut.SGW-LB-V6] gtp-u yes ; commit"    
    dut exec config "zone default gateway sgw SGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW s1u-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6"
    dut exec config "zone default gateway sgw SGW-1 s5-s8-interface-network-context S2B-PGW s5-s8-gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn.epdg-access-pi.net ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn2.epdg-access-pi.net ; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C851971
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/14/2016
set pctComp   100
set summary   "Support for configuring GTP-C on v6v4 ePDG loopback address ; Primary - v6 Secondary - v4 ; Check is session is successful"
set descr     "
1.  Set ePDG & PGW GTP-c Loopbacks as V6V4
2.  Bring up the session and check the Data Path
3.  Get the Source and Destination IP addresses of the GTP-C messages
4.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
5.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages
6.  Find out the Ping Packets from UE to OS to verify  data path on S2B interface"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Set ePDG & PGW GTP-C Loopbacks as V6V4" {
                
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V4"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
            dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V4 ; commit"            
            dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
            log.test "S2B-EPDG GTP-C ON V6V4"
        } else {
            error.an "Unable to set S2B-EPDG GTP-C as V6V4 Loopback IP"
        }
            
        if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6 secondary-loopback-ip PGW-LB-V4"] == 1 } {            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
            dut exec config "no zone default gateway pgw PGW-1 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6 secondary-loopback-ip PGW-LB-V4 ; commit"            
            dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
            dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
            log.test "S2B-PGW GTP-C ON V6V4 Only"
        } else {
            error.an "Unable to set S2B-PGW GTP-C as V6V4 Loopback IP"
        }
        
        dut exec config "zone default gateway sgw SGW-1 admin-state disabled ; commit"        
        dut exec config "no zone default gateway sgw ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"        
        dut exec config "no network-context S2B-PGW loopback-ip SGW-LB-V4 ; commit" 
        
    }
    
    runStep "Bring up the session and check the Data Path" {
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
         
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_pgw
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_pgw
        
        if { [string match $ip1 $ipv4_epdg] == 1 && [string match $ip2 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet CSRs"
        } elseif { [string match $ip1 $ipv6_epdg] == 1 && [string match $ip2 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet CSRs"
        } else {
            error.an "Tunnel Endpoint addresses do not match with the Source and Dest. addresses for GTP-C packet CSRs"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Bearer Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for Bearer request and response"
        }
        
        if { [string match $ip2 $ipv4_epdg] == 1 && [string match $ip1 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet CBRs"
        } elseif { [string match $ip2 $ipv6_epdg] == 1 && [string match $ip1 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet CBRs"
        } else {
            error.an "Tunnel Endpoint addresses do not match with the Source and Dest. addresses for GTP-C packet CBRs"
        }
        
    }
    
    runStep "Find out the Ping Packets from UE to OS to verify GTP-ICMP data path on S2B interface" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
        tshark exec "tshark -r /tmp/umakant -Y 'gtp and icmp'"
        
        if { [tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipv4_epdg and ip.addr==$ipv4_pgw and icmp' | grep 'request'  | wc -l"] != 0 } {
            set out [tshark exec "tshark -r /tmp/umakant -Y 'ip.addr==$ipv4_epdg and ip.addr==$ipv4_pgw and icmp' | grep 'request'  | wc -l"]
            regexp.an -all -lineanchor {\s*([0-9]+)} $out - ping_packet_count
        } else {
            set out [tshark exec "tshark -r /tmp/umakant -Y 'ipv6.addr==$ipv6_epdg and ipv6.addr==$ipv6_pgw and icmp' | grep 'request'  | wc -l"]
            regexp.an -all -lineanchor {\s*([0-9]+)} $out - ping_packet_count
        }
        
        if { $ping_packet_count == 20 } {
            log.test "Data packets between ePDG and PGW on S2B are passing through GTP Tunnel"
        } else {
            error.an "Data packets between ePDG and PGW on S2B are not passing through GTP Tunnel"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V4 ip-address [tb _ dut.SGW-LB-V4] gtp-u yes ; commit"    
    dut exec config "network-context S2B-PGW loopback-ip SGW-LB-V6 ip-address [tb _ dut.SGW-LB-V6] gtp-u yes ; commit"    
    dut exec config "zone default gateway sgw SGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW s1u-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6"
    dut exec config "zone default gateway sgw SGW-1 s5-s8-interface-network-context S2B-PGW s5-s8-gtpc-endpoint-params network-context S2B-PGW loopback-ip SGW-LB-V6 ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn.epdg-access-pi.net ; commit"    
    dut exec config "zone default gateway sgw SGW-1 apn-list apn2.epdg-access-pi.net ; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778986
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/9/2016
set pctComp   100
set summary   "Verify if Primary loopback is v4 then secondary must be v6 or vice versa; Both Primary and secondary should not be of same type"
set descr     "Verify if Primary loopback is v4 then secondary must be v6 or vice versa; Both Primary and secondary should not be of same type"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Verify if Primary loopback is v4 then secondary must be v6 or vice versa; Both Primary and secondary should not be of same type" {
        
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled"
        dut exec config "commit"
        
        catch {dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V4 ; commit"} result
        dut exec config "no zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V4 ; commit"
        
        if { [regexp.an "'zone default gateway epdg': The primary and secondary S2B GTPc endpoint loopback IPs cannot be of the same type" $result] } {
            log.test "S2B GTPc endpoint loopback IPs cannot be of the same type - Functionality Verified"
        } else {
            error.an "S2B GTPc endpoint loopback IPs cannot be of the same type - Unable to verify this Functionality"
        }
        
        catch {dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip SWM-LB-V4 ; commit"} result
        dut exec config "no zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip SWM-LB-V4 ; commit"
        
        if { [regexp.an "'zone default gateway epdg': The primary and secondary S2B GTPc endpoint loopback IPs cannot be of the same type" $result] } {
            log.test "S2B GTPc endpoint loopback IPs cannot be of the same type - Functionality Verified"
        } else {
            error.an "S2B GTPc endpoint loopback IPs cannot be of the same type - Unable to verify this Functionality"
        }
        
        catch {dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip SWM-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V4 ; commit"} result
        dut exec config "no zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip SWM-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V4 ; commit"
        
        if { [regexp.an "'zone default gateway epdg': The primary and secondary S2B GTPc endpoint loopback IPs cannot be of the same type" $result] } {
            log.test "S2B GTPc endpoint loopback IPs cannot be of the same type - Functionality Verified"
        } else {
            error.an "S2B GTPc endpoint loopback IPs cannot be of the same type - Unable to verify this Functionality"
        }
        
        catch {dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"} result
        dut exec config "no zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"
        
        if { [regexp.an "'zone default gateway epdg': The primary and secondary S2B GTPc endpoint loopback IPs cannot be of the same type" $result] } {
            log.test "S2B GTPc endpoint loopback IPs cannot be of the same type - Functionality Verified"
        } else {
            error.an "S2B GTPc endpoint loopback IPs cannot be of the same type - Unable to verify this Functionality"
        }
        
        catch {dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip SWM-LB-V6 ; commit"} result
        dut exec config "no zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip SWM-LB-V6 ; commit"
        
        if { [regexp.an "'zone default gateway epdg': The primary and secondary S2B GTPc endpoint loopback IPs cannot be of the same type" $result] } {
            log.test "S2B GTPc endpoint loopback IPs cannot be of the same type - Functionality Verified"
        } else {
            error.an "S2B GTPc endpoint loopback IPs cannot be of the same type - Unable to verify this Functionality"
        }
        
        catch {dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip SWM-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"} result
        dut exec config "no zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip SWM-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"
        
        if { [regexp.an "'zone default gateway epdg': The primary and secondary S2B GTPc endpoint loopback IPs cannot be of the same type" $result] } {
            log.test "S2B GTPc endpoint loopback IPs cannot be of the same type - Functionality Verified"
        } else {
            error.an "S2B GTPc endpoint loopback IPs cannot be of the same type - Unable to verify this Functionality"
        }
          
    }
    
} {
    # Cleanup    
    catch {dut exec config "zone default gateway epdg EPDG-1 admin-state disabled"}
    catch {dut exec config "commit"}
    catch {dut exec config "no zone default gateway epdg EPDG-1"}
    catch {dut exec config "commit"}
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6"
    dut exec config "commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net"
    dut exec config "commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net"
    dut exec config "commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net"
    dut exec config "commit"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C281147
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/14/2016
set pctComp   100
set summary   "Bounce admin state/reboot and verify the call flow"
set descr     "
1.  Bring up the session and check the Data Path ; Bounce admin state
2.  Check if no any session/tunnel is active/present
3.  Bring up the session and check the Data Path ; verify the call flow"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Bring up the session and check the Data Path ; Bounce admin state" {    
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec config "network-context SWU security disabled"
        dut exec config "commit"
        
        dut exec config "network-context SWU security enabled"
        dut exec config "commit"
        
        sleep 90
    
    }
        
    runStep "Check if no any session/tunnel is active/present" {
        
        set out [dut exec "show subscriber summary gateway-type epdg"]
        
        if { [regexp.an "No entries found." $out] } {
            log.test "No any epdg session found"
        } else {
            error.an "Found epdg session"
        }
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 0 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 0} {
            log.test "No any IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 0"
        }
		
    }
    
    runStep "Bring up the session and check the Data Path and verify the call flow" {    
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
                
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "network-context SWU security enabled"
    dut exec config "commit"
    sleep 90
    ePDG:mcc_crash_checkup
}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
    if { $i ==0 } {
        set id        ePDG:section1:EPDG:C778970
        set summary   "Verify the signalling (on v4) when ePDG loopback is v4 only and PGW is v4v6"
    } else {
        set id        ePDG:section1:EPDG:C852218
        set summary   "Verify the signalling (on v4) when PGW loopback is v4 only and ePDG is v4v6"
    }
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/15/2016
set pctComp   100
set descr     "
1.  Set ePDG & PGW GTP-c Loopbacks as V4 Only
2.  Bring up the session and check the Data Path
3.  Get the Source and Destination IP addresses of the GTP-C messages
4.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
5.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Set ePDG & PGW GTP-C Loopbacks as V4 Only" {
        
        if { $i == 0 } {
          
            if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4"] == 1 } {            
                dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 ; commit"            
                dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
                log.test "S2B-EPDG GTP-C ON V4 Only"
            } else {
                error.an "Unable to set S2B-EPDG GTP-C as V4 Only Loopback IP"
            }
            
            if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6 secondary-loopback-ip PGW-LB-V4"] == 1 } {            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
                dut exec config "no zone default gateway pgw PGW-1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6 secondary-loopback-ip PGW-LB-V4 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
                log.test "S2B-PGW GTP-C ON V6V4 Only"
            } else {
                error.an "Unable to set S2B-PGW GTP-C as V6V4 Loopback IP"
            }
            
        } else {
            
            if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V4"] == 1 } {            
                dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 secondary-loopback-ip S2B-EPDG-LB-V4 ; commit"            
                dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
                log.test "S2B-EPDG GTP-C ON V6V4"
            } else {
                error.an "Unable to set S2B-EPDG GTP-C as V6V4 Loopback IP"
            }
            
            if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4"] == 1 } {            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
                dut exec config "no zone default gateway pgw PGW-1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
                log.test "S2B-PGW GTP-C ON V4 Only"
            } else {
                error.an "Unable to set S2B-PGW GTP-C as V4 Only Loopback IP"
            }       
            
        }
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping6_os $ipsec(ueIp6)
        ePDG:ue_ping6_os2 $ipsec(ueIp6)
        ePDG:ue_tcp6_os $ipsec(ueIp6)
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
         
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v4-ip-address\s+([0-9.]+)$} $out - ipv4_pgw
        
        if { [string match $ip1 $ipv4_epdg] == 1 && [string match $ip2 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet for CSRs"
        } else {
            error.an "Tunnel Endpoint IPv4 addresses do not match with the Source and Dest. IPv4 addresses for GTP-C packet for CSRs"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Bearer Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for Bearer request and response"
        }
        
        if { [string match $ip2 $ipv4_epdg] == 1 && [string match $ip1 $ipv4_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv4 addresses match with the Source and Dest. IPv4 addresses for GTP-C packet for CBRs"
        } else {
            error.an "Tunnel Endpoint IPv4 addresses do not match with the Source and Dest. IPv4 addresses for GTP-C packet for CBRs"
        }
        
    }
    
    
} {
    # Cleanup
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}
}

# ==============================================================
for {set i 0} {$i < 2} {incr i} {
    if { $i ==0 } {
        set id        ePDG:section1:EPDG:C778971
        set summary   "Verify the signalling (on v6) when ePDG loopback is v6 only and PGW is v4v6"
    } else {
        set id        ePDG:section1:EPDG:C852219
        set summary   "Verify the signalling (on v6) when PGW loopback is v6 only and ePDG is v4v6"
    }
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/15/2016
set pctComp   100
set descr     "
1.  Set ePDG & PGW GTP-c Loopbacks as V6 Only
2.  Bring up the session and check the Data Path
3.  Get the Source and Destination IP addresses of the GTP-C messages
4.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
5.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Set ePDG & PGW GTP-C Loopbacks as V6 Only" {
              
        if { $i == 0 } {
          
            if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6"] == 1 } {            
                dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ; commit"            
                dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
                log.test "S2B-EPDG GTP-C ON V4 Only"
            } else {
                error.an "Unable to set S2B-EPDG GTP-C as V4 Only Loopback IP"
            }
            
            if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4 secondary-loopback-ip PGW-LB-V6"] == 1 } {            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
                dut exec config "no zone default gateway pgw PGW-1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V4 secondary-loopback-ip PGW-LB-V6 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
                log.test "S2B-PGW GTP-C ON V6V4 Only"
            } else {
                error.an "Unable to set S2B-PGW GTP-C as V6V4 Loopback IP"
            }
            
        } else {
            
            if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V6"] == 1 } {            
                dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip ; commit"
                dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"            
                dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"            
                log.test "S2B-EPDG GTP-C ON V4V6"
            } else {
                error.an "Unable to set S2B-EPDG GTP-C as V4V6 Loopback IP"
            }
            
            if { [dut . configurator testCmd "zone default gateway pgw PGW-1 gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6"] == 1 } {            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW ; no key key1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 admin-state disabled ; commit"            
                dut exec config "no zone default gateway pgw PGW-1 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6 ; commit"            
                dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net ; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net ; commit"            
                dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1 ; commit"            
                log.test "S2B-PGW GTP-C ON V6 Only"
            } else {
                error.an "Unable to set S2B-PGW GTP-C as V6 Only Loopback IP"
            }       
            
        }
        
    }
    
    runStep "Bring up the session and check the Data Path" {
       
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 startcapture count 10000 duration 600 file-name umakant"
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "network-context S2B-PGW ip-interface S2B-PGW-5-1 stopcapture"
        
        import_tshark_file
         
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-zA-Z]+)$} $out - ipv6_pgw
        
        if { [string match $ip1 $ipv6_epdg] == 1 && [string match $ip2 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet for CSRs"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet for CSRs"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C Bearer messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Bearer Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Bearer Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for Bearer request and response"
        }
        
        if { [string match $ip2 $ipv6_epdg] == 1 && [string match $ip1 $ipv6_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet for CBRs"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet for CBRs"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}
}

# ==============================================================
set id        ePDG:section1:EPDG:C778959
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/16/2016
set pctComp   100
set summary   "Verify the ePDG loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint or Secondary GTPC endpoint"
set descr     "Verify the ePDG loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint or Secondary GTPC endpoint"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Verify the ePDG loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint or Secondary GTPC endpoint" {
        
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled ; commit"
        dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params loopback-ip; commit"
        dut exec config "zone default gateway epdg EPDG-1 ; no s2b-gtpc-endpoint-params secondary-loopback-ip; commit"
        dut exec config "zone default gateway epdg EPDG-1 s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 secondary-loopback-ip S2B-EPDG-LB-V6 ; commit"            
        dut exec config "zone default gateway epdg EPDG-1 admin-state enabled ; commit"         
                
        catch {dut exec config "network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 ip-address 3.4.8.6 ; commit"} result
        
        if { [regexp.an "\'network-context S2B-EPDG loopback-ip\': Loopback entry is in use. Can't be deleted/modified" $result] } {
            log.test "ePDG V4 loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint - Functionality Verified"
        } else {
            error.an "ePDG V4 loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint - Unable to verify this Functionality"
        }
        
        catch {dut exec config "network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address 3.4.5.6; commit"} result
        
        if { [regexp.an "\'network-context S2B-EPDG loopback-ip\': Loopback entry is in use. Can't be deleted/modified" $result] } {
            log.test "ePDG V6 loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint - Functionality Verified"
        } else {
            error.an "ePDG V6 loopback ip address can not be modified when it is associated with a Gateway GTPC endpoint - Unable to verify this Functionality"
        }
        
    }
    
} {
    # Cleanup    
    catch {dut exec config "zone default gateway epdg EPDG-1 admin-state disabled"}
    catch {dut exec config "commit"}
    catch {dut exec config "no zone default gateway epdg EPDG-1"}
    catch {dut exec config "commit"}
    dut exec config "network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V4 ip-address [tb _ dut.S2B-EPDG-LB-V4] gtp-u yes; commit"
    dut exec config "network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6 ip-address [tb _ dut.S2B-EPDG-LB-V6] gtp-u yes; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"    
    ePDG:mcc_crash_checkup
    
}

# ==============================================================
set id        ePDG:section1:EPDG:C778958
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/19/2016
set pctComp   100
set summary   "Verify sessions are deleted after Admin Down of ePDG"
set descr     "
1.  Capture the packets on S2B interface and start the session ; Disable ePDG
2.  Check if no any session/tunnel is active/present
3.  Find the Tunnel endpoint IP addresses
4.  Verify ePDG is sending Delete Session Request to PGW with corresponding TEID
5.  Verify PGW is sending Delete Session Response to ePDG with corresponding TEID
6.  Verify the TEIDs
7.  Verify if only one Delete session request and delete session response is present"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Capture the packets on S2B interface and start the session ; Disable ePDG" {
        
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
        
        sleep 10
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Check if no any session/tunnel is active/present" {
        
        set out [dut exec "show subscriber summary gateway-type epdg"]
        
        if { [regexp.an "No entries found." $out] } {
            log.test "No any epdg session found"
        } else {
            error.an "Found epdg session"
        }
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 0 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 0} {
            log.test "No any IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 0"
        }
		
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-value\s+([0-9]+)$} $sessionInfo - teidOut] } {
            log.test "network-out-control-teid-value: $teidOut"
        } else {
            error.an "Unable to find Network-out-control-teid-value"
        }
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-value\s+([0-9]+)$} $sessionInfo - teidIn] } {
            log.test "network-in-control-teid-value: $teidIn"
        } else {
            error.an "Unable to find Network-in-control-teid-value"
        }
        
    }
    
    runStep "Verify ePDG is sending Delete Session Request to PGW with corresponding TEID" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2' | grep -e \"Delete Session Request\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gtpv2.message_type\" showname=\"Message Type: Delete Session Request} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.teid\" showname=\"Tunnel Endpoint Identifier: ([0-9a-zA-Z]+) \(([0-9]+)\)\"} $packetInfo - hexval teid1] == 1 } {             
            log.test "ePDG is sending Delete Session Request to PGW with TEID : $teid1"
        } else {
            error.an "Unable to find Delete Session Request from ePDG to PGW"
        }
        
    }
    
    runStep "Verify PGW is sending Delete Session Response to ePDG with corresponding TEID" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1' | grep -e \"Delete Session Response\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gtpv2.message_type\" showname=\"Message Type: Delete Session Response} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.teid\" showname=\"Tunnel Endpoint Identifier: ([0-9a-zA-Z]+) \(([0-9]+)\)\"} $packetInfo - hexval teid2] == 1 &&
             [regexp.an {<field name=\"gtpv2.ie_type\" showname=\"IE Type: Cause \(2\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.cause\" showname=\"Cause: Request accepted \(16\)\"} $packetInfo] == 1 } {             
            log.test "PGW is sending Delete Session Response to ePDG with TEID : $teid2"
        } else {
            error.an "Unable to find Delete Session Response from PGW to ePDG"
        }
        
    }
    
    runStep "Verify the TEIDs" {
        
        if { $teidOut == $teid1 && $teidIn == $teid2 } {
            log.test "TEIDs in DSR match with the one on MCC"
        } else {
            error.an "TEID in DSR do not match with the one on MCC"
        }
		
    }
    
    runStep "Verify if only one Delete session request and delete session response is present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Session Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "Only one Delete session request and delete session response is present"
        } else {
            error.an "More than one Delete session request and delete session response is present ; Expected is only one Transaction"
        }
		
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1 admin-state enabled; commit"        
    ePDG:clear_tshark_data
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778944
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/20/2016
set pctComp   100
set summary   "Verify gtp-u PathMgmt 'gtp-u-echo-interval' configuration and modification functionality on ePDG"
set descr     "
1.  Remove and add again the gateways to clear gtp status table on MCC
2.  Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms
3.  Record the zone default gateway cluster-level gtp peer statistics
4.  Capture the packets on S2B interface and start the session
5.  Find the Tunnel endpoint IP addresses
6.  Record the zone default gateway cluster-level gtp peer statistics after the Session
7.  Verify that gtp-peer-status table is present with peer status as up on ePDG & PGW network contexts
8.  Verify if Three Echo requests and Echo responses are present
9.  Verify the Stats on MCC with the PCAP"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Remove and add again the gateways to clear gtp status table on MCC" {
        
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"
        sleep 10
        dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
        dut exec config "no zone default gateway epdg EPDG-1; commit"
        dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
        dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
        dut exec config "no zone default gateway pgw PGW-1; commit"    
        dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
        dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
        
    }
    
    runStep "Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"                
            log.test "gtp-echo-interval is configure as 60000 ms"
        } else {
            error.an "Unable to configure gtp-echo-interval as 60000 ms"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true; commit"                
            log.test "initiate-gtp-u-echo-requests is configure true"
        } else {
            error.an "Unable to configure initiate-gtp-u-echo-requests as true"
        }   
        
        set out [dut exec "show zone default gateway statistics cluster-level gtp peer | include \"gateway statistics cluster-level gtp peer\" | include [tb _ dut.chassisNumber]"]
        set lines [ePDG:numberOfLines $out]
        if { $lines == 0 } {
            puts "No GTP Peer is present"
        } elseif { $lines == 1 } {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
        } else {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            set val 12
            for {set i 2 } { $i < [expr $lines + 1] } { incr i} {
                set peer [lrange $out $val $val]
                set val [expr $val + 7]
                catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            }
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics" {
        
        set ePDGreqrece1 0
        set ePDGreqsent1 0
        set ePDGresrece1 0
        set ePDGressent1 0
        
        set PGWreqrece1 0
        set PGWreqsent1 0
        set PGWresrece1 0
        set PGWressent1 0
        
    }

    runStep "Capture the packets on S2B interface and start the session" {
                
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        sleep 180
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics after the Session" {
        
        set epdgPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-EPDG-EPDG-1-$ip2 [tb _ dut.chassisNumber]"]
        set pgwPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-PGW-PGW-1-$ip1 [tb _ dut.chassisNumber]"]
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $epdgPeer - ePDGreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $epdgPeer - ePDGreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $epdgPeer - ePDGresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $epdgPeer - ePDGressent2
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $pgwPeer - PGWreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $pgwPeer - PGWreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $pgwPeer - PGWresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $pgwPeer - PGWressent2              
        
    }
    
    runStep "Verify that gtp-peer-status table is present with peer status as up on ePDG & PGW network contexts" {
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-EPDG"        
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt >= 1 } {   
            log.test "gtp-peer-status table is present with peer status as up on ePDG network context"
        } else {
            error.an "gtp-peer-status table should be present with peer status as \"UP\" on ePDG network context"
        }
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-PGW"
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt >= 1 } {   
            log.test "gtp-peer-status table is present with peer status as up on PGW network context"
        } else {
            error.an "gtp-peer-status table should be present with peer status as \"UP\" on PGW network context"
        }
        
    }
    
    runStep "Verify if Three Echo requests and Echo responses are present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 3 && $respns == 3 } {
            log.test "ePDG is sending Three Echo requests and receiving three Echo responses"
        } else {
            error.an "ePDG is not sending Three Echo requests and receiving three Echo responses"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 3 && $respns == 3 } {
            log.test "PGW is sending Three Echo requests and receiving three Echo responses"
        } else {
            error.an "PGW is not sending Three Echo requests and receiving three Echo responses"
        }
		
    }
    
    runStep "Verify the Stats on MCC with the PCAP" {
        
        if { $ePDGreqrece2 == $ePDGreqrece1 + 3 && $ePDGreqsent2 == $ePDGreqsent1 + 3 && $ePDGresrece2 == $ePDGresrece1 + 3 && $ePDGressent2 == $ePDGressent1 + 3 } {             
            log.test "ePDG Peer stats Verified"
        } else {
            error.an "Unable to verify ePDG Peer stats"
        }
        
        if { $PGWreqrece2 == $PGWreqrece1 + 3 && $PGWreqsent2 == $PGWreqsent1 + 3 && $PGWresrece2 == $PGWresrece1 + 3 && $PGWressent2 == $PGWressent1 + 3 } {             
            log.test "PGW Peer stats Verified"
        } else {
            error.an "Unable to verify PGW Peer stats"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true; commit"                
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778945:C778946:C778966
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/20/2016
set pctComp   100
set summary   "Verify gtp-u PathMgmt 'gtp-u-echo-response-timeout' & 'gtp-u-echo-retransmit-count' configuration and modification functionality on ePDG &
               Check GTP Peer stats - show zone default gateway statistics cluster-level gtp peer"
set descr     "
1.  Remove and add again the gateways to clear gtp status table on MCC
2.  Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms
3.  Stop SWM Server and check if 'Dummy' PGW IP address is not configured on MCC
4.  Change PDN type flag to '2' to make it IPv4Ipv6 session
5.  Record the zone default gateway cluster-level gtp peer statistics
6.  Capture the packets on S2B interface and start the session
7.  Find the Tunnel endpoint IP addresses
8.  Record the zone default gateway cluster-level gtp peer statistics after the Session
9.  Verify that gtp-peer-status table is present with peer status as up on ePDG & PGW network contexts
10. Verify if One Echo request and Echo response is present
11. Verify if ePDG is sending Three Echo requests to Dummy PGW Peer
12. Verify ePDG is Retransmitting the Echo requests to Dummy PGW Peer after ~2 seconds
13. Verify the GTP peer Stats on MCC with the PCAP"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Remove and add again the gateways to clear gtp status table on MCC" {
        
        ePDG:checkSessionState
        dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
        dut exec config "no zone default gateway epdg EPDG-1; commit"
        dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
        dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
        dut exec config "no zone default gateway pgw PGW-1; commit"    
        dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
        dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
        
        
    }
    
    runStep "Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms" {
       
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"                
            log.test "gtp-echo-interval is configure as 60000 ms"
        } else {
            error.an "Unable to configure gtp-echo-interval as 60000 ms"
        }
        
        
        set out [dut exec "show zone default gateway statistics cluster-level gtp peer | include \"gateway statistics cluster-level gtp peer\" | include [tb _ dut.chassisNumber]"]
        set lines [ePDG:numberOfLines $out]
        if { $lines == 0 } {
            puts "No GTP Peer is present"
        } elseif { $lines == 1 } {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
        } else {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            set val 12
            for {set i 2 } { $i < [expr $lines + 1] } { incr i} {
                set peer [lrange $out $val $val]
                set val [expr $val + 7]
                catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            }
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics" {
        
        set ePDGreqrece1 0
        set ePDGreqsent1 0
        set ePDGresrece1 0
        set ePDGressent1 0
        
        set ePDGdummyreqsent1 0
        
        set PGWreqrece1 0
        set PGWreqsent1 0
        set PGWresrece1 0
        set PGWressent1 0
        
    }
    
    runStep "Stop SWM Server and check if 'Dummy' PGW IP address is not configured on MCC" {
        
        swm init
        swm stop
        sleep 5
        
        set dummyIp "2001:470:8865:4087:87::[format %x [tb _ dut.chassisNumber]]"
        
        dut exec "show running-config service-construct pdngw-list ip-address"
        
        if { [string match $dummyIp [cmd_out dump]] == 0} {
            log.test "PGW address set as $dummyIp"
        } else {
            error.an "Choose different IP address"
        }
        
    }   
        
    runStep "Change PDN type flag to '2' to make it IPv4Ipv6 session" {
        
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION," str2 "serviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);"
        ePDG:replaceStringSwm str1 "AVP_Address(ProtocolConstants.DI_MIP_HOME_AGENT_ADDRESS," str2 "pgwaddr = AVP_Address(ProtocolConstants.DI_MIP_HOME_AGENT_ADDRESS, \"$dummyIp\");"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_MIP6_AGENT_INFO," str2 "agentinfo = AVP_Grouped(ProtocolConstants.DI_MIP6_AGENT_INFO, \[pgwaddr\]);"
        ePDG:replaceStringSwm str1 "AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDNGWALLOCATIONTYPE," str2 "pdngwalloctype = AVP_Unsigned32(ProtocolConstants.DI_3GPP_PDNGWALLOCATIONTYPE, 0, ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION," str2 "apnconfiguration = AVP_Grouped(ProtocolConstants.DI_3GPP_APN_CONFIGURATION, \[ agentinfo, serviceselection, pdngwalloctype \], ProtocolConstants.DI_3GPP_VENDOR_ID);"
        ePDG:replaceStringSwm str1 "apnconfiguration.setM()" str2 "apnconfiguration.setM()"
        ePDG:replaceStringSwm str1 "answer.append(apnconfiguration)" str2 "answer.append(apnconfiguration)"
        ePDG:replaceStringSwm str1 "AVP_UTF8String(ProtocolConstants.DI_STATE," str2 "state = AVP_UTF8String(ProtocolConstants.DI_STATE, \"cookie\");"
        ePDG:replaceStringSwm str1 "answer.append(state)" str2 "answer.append(state)"
        
        #swm exec "sed -i '/#.*AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION,/s/.*/\\t\\tserviceselection = AVP_UTF8String(ProtocolConstants.DI_SERVICE_SELECTION, apnstr);/' [swm . workDirAbsolutePath]/swm/swmserver.py"
        swm start
        
    }

    runStep "Capture the packets on S2B interface and start the session" {
                
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        sleep 100
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics after the Session" {
        
        set epdgPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-EPDG-EPDG-1-$ip2 [tb _ dut.chassisNumber]"]
        set epdgPeer2 [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-EPDG-EPDG-1-$dummyIp [tb _ dut.chassisNumber]"]
        set pgwPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-PGW-PGW-1-$ip1 [tb _ dut.chassisNumber]"]
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $epdgPeer - ePDGreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $epdgPeer - ePDGreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $epdgPeer - ePDGresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $epdgPeer - ePDGressent2
        
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $epdgPeer2 - ePDGdummyreqsent2
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $pgwPeer - PGWreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $pgwPeer - PGWreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $pgwPeer - PGWresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $pgwPeer - PGWressent2              
        
    }
    
    runStep "Verify that gtp-peer-status table is present with peer status as up on ePDG & PGW network contexts" {
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-EPDG"        
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt >= 1 } {   
            log.test "gtp-peer-status table is present with peer status as up on ePDG network context"
        } else {
            error.an "gtp-peer-status table should be present with peer status as \"UP\" on ePDG network context"
        }
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-PGW"
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt >= 1 } {   
            log.test "gtp-peer-status table is present with peer status as up on PGW network context"
        } else {
            error.an "gtp-peer-status table should be present with peer status as \"UP\" on PGW network context"
        }
        
    }
    
    runStep "Verify if One Echo request and Echo response is present" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "ePDG is sending one Echo request and receiving one Echo responses"
        } else {
            error.an "ePDG is sending $reqsts Echo requests and receiving $respns Echo responses; Expected is 1"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "PGW is sending one Echo requests and receiving one Echo responses"
        } else {
            error.an "PGW is sending $reqsts Echo requests and receiving $respns Echo responses; Expected is 1"
        }
        
    }
    
    runStep "Verify if ePDG is sending Three Echo requests to Dummy PGW Peer" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$dummyIp'  | grep -e \"Echo Request\" | wc -l"]        
                
        if { $reqsts == 3 } {
            log.test "ePDG is sending Three Echo requests to Dummy PGW Peer"
        } else {
            error.an "ePDG is not sending Three Echo requests to Dummy PGW Peer"
        }
        
    }
    
    runStep "Verify ePDG is Retransmitting the Echo requests to Dummy PGW Peer after ~2 seconds" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$dummyIp'"
        
        set t1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$dummyIp'  | grep -e \"Echo Request\" | awk  '{print \$2}' | sed -n '1p'"]
        set t2 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$dummyIp'  | grep -e \"Echo Request\" | awk  '{print \$2}' | sed -n '2p'"]
        set t3 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$dummyIp'  | grep -e \"Echo Request\" | awk  '{print \$2}' | sed -n '3p'"]        
                               
        if { [set t4 [expr $t3 - $t2 ]] > 1.99 && [expr $t3 - $t2 ] < 3  } {
            log.test "ePDG is Retransmitting the Echo requests to Dummy PGW Peer after $t4 seconds"
        } else {
            error.an "ePDG is Retransmitting the Echo requests to Dummy PGW Peer after $t4 seconds ; Expected is ~1.99 to 2 seconds"
        }
        
        if { [set t5 [expr $t2 - $t1 ]] > 1.99 && [expr $t2 - $t1 ] < 3  } {
            log.test "ePDG is Retransmitting the Echo requests to Dummy PGW Peer after $t5 seconds"
        } else {
            error.an "ePDG is Retransmitting the Echo requests to Dummy PGW Peer after $t5 seconds ; Expected is ~1.99 to 2 seconds"
        }
        
    }
    
    runStep "Verify the GTP peer Stats on MCC with the PCAP" {
        
        if { $ePDGreqrece2 == $ePDGreqrece1 + 1 && $ePDGreqsent2 == $ePDGreqsent1 + 1 && $ePDGresrece2 == $ePDGresrece1 + 1 && $ePDGressent2 == $ePDGressent1 + 1 } {             
            log.test "ePDG Peer stats Verified"
        } else {
            error.an "Unable to verify ePDG Peer stats"
        }
        
        if { $PGWreqrece2 == $PGWreqrece1 + 1 && $PGWreqsent2 == $PGWreqsent1 + 1 && $PGWresrece2 == $PGWresrece1 + 1 && $PGWressent2 == $PGWressent1 + 1 } {             
            log.test "PGW Peer stats Verified"
        } else {
            error.an "Unable to verify PGW Peer stats"
        }
        
        if { $ePDGdummyreqsent2 == $ePDGdummyreqsent1 + 3 } {             
            log.test "ePDG Dummy Peer stats Verified"
        } else {
            error.an "Unable to verify ePDG Dummy Peer stats"
        }
        
    }
    
} {
    # Cleanup
    swm stop
    swm init
    sleep 5
    ePDG:clear_tshark_data    
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true; commit"                
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778972
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/20/2016
set pctComp   100
set summary   "Verify gtp-u PathMgmt 'initiate-gtp-u-echo-requests' configuration and modification functionality on ePDG"
set descr     "
1.  Remove and add again the gateways to clear gtp status table on MCC
2.  Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms
3.  Record the zone default gateway cluster-level gtp peer statistics
4.  Capture the packets on S2B interface and start the session
5.  Find the Tunnel endpoint IP addresses
6.  Record the zone default gateway cluster-level gtp peer statistics after the Session
7.  Verify that gtp-peer-status table is not present with peer status as up on ePDG & PGW network contexts
8.  Verify if No any Echo requests and Echo responses are present
9.  Verify the Stats on MCC with the PCAP"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Remove and add again the gateways to clear gtp status table on MCC" {
        
        ePDG:checkSessionState
        dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
        dut exec config "no zone default gateway epdg EPDG-1; commit"
        dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
        dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
        dut exec config "no zone default gateway pgw PGW-1; commit"    
        dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
        dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
        
    }
    
    runStep "Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"                
            log.test "gtp-echo-interval is configure as 60000 ms"
        } else {
            error.an "Unable to configure gtp-echo-interval as 60000 ms"
        }        
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests false"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests false; commit"                
            log.test "initiate-gtp-u-echo-requests is configure false"
        } else {
            error.an "Unable to configure initiate-gtp-u-echo-requests as false"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common PGW-PROFILE initiate-echo-requests false"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common PGW-PROFILE initiate-echo-requests false; commit"                
            log.test "initiate-gtp-u-echo-requests is configure false"
        } else {
            error.an "Unable to configure initiate-gtp-u-echo-requests as false"
        }
    
        set out [dut exec "show zone default gateway statistics cluster-level gtp peer | include \"gateway statistics cluster-level gtp peer\" | include [tb _ dut.chassisNumber]"]
        set lines [ePDG:numberOfLines $out]
        if { $lines == 0 } {
            puts "No GTP Peer is present"
        } elseif { $lines == 1 } {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
        } else {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            set val 12
            for {set i 2 } { $i < [expr $lines + 1] } { incr i} {
                set peer [lrange $out $val $val]
                set val [expr $val + 7]
                catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            }
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics" {
        
        set ePDGreqrece1 0
        set ePDGreqsent1 0
        set ePDGresrece1 0
        set ePDGressent1 0
        
        set PGWreqrece1 0
        set PGWreqsent1 0
        set PGWresrece1 0
        set PGWressent1 0
        
    }

    runStep "Capture the packets on S2B interface and start the session" {
                
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        sleep 175
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics after the Session" {
        
        set epdgPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-EPDG-EPDG-1-$ip2 [tb _ dut.chassisNumber]"]
        set pgwPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-PGW-PGW-1-$ip1 [tb _ dut.chassisNumber]"]
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $epdgPeer - ePDGreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $epdgPeer - ePDGreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $epdgPeer - ePDGresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $epdgPeer - ePDGressent2
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $pgwPeer - PGWreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $pgwPeer - PGWreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $pgwPeer - PGWresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $pgwPeer - PGWressent2              
        
    }
    
    runStep "Verify that gtp-peer-status table is not present with peer status as up on ePDG & PGW network contexts" {
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-EPDG"        
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt == 0 } {   
            log.test "gtp-peer-status table is not present with peer status as up on ePDG network context"
        } else {
            error.an "gtp-peer-status table should not be present with peer status as \"UP\" on ePDG network context"
        }
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-PGW"
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt == 0 } {   
            log.test "gtp-peer-status table is not present with peer status as up on PGW network context"
        } else {
            error.an "gtp-peer-status table should not be present with peer status as \"UP\" on PGW network context"
        }
        
    }
    
    runStep "Verify if No any Echo requests and Echo responses are present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 0 && $respns == 0 } {
            log.test "ePDG is not sending any Echo requests and not receiving any Echo responses"
        } else {
            error.an "ePDG is sending $reqsts Echo requests and receiving $respns Echo responses"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 0 && $respns == 0 } {
            log.test "PGW is not sending 3 Echo requests and not receiving any Echo responses"
        } else {
            error.an "PGW is sending $reqsts Echo requests and receiving $respns Echo responses"
        }
		
    }
    
    runStep "Verify the Stats on MCC with the PCAP" {
        
        if { $ePDGreqrece2 == $ePDGreqrece1 + 0 && $ePDGreqsent2 == $ePDGreqsent1 + 0 && $ePDGresrece2 == $ePDGresrece1 + 0 && $ePDGressent2 == $ePDGressent1 + 0 } {             
            log.test "ePDG Peer stats Verified"
        } else {
            error.an "Unable to verify ePDG Peer stats"
        }
        
        if { $PGWreqrece2 == $PGWreqrece1 + 0 && $PGWreqsent2 == $PGWreqsent1 + 0 && $PGWresrece2 == $PGWresrece1 + 0 && $PGWressent2 == $PGWressent1 + 0 } {             
            log.test "PGW Peer stats Verified"
        } else {
            error.an "Unable to verify PGW Peer stats"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true; commit"                
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"
    dut exec config "zone default gateway profile gateway-common PGW-PROFILE initiate-echo-requests true; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778975:C778947:C778967
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/21/2016
set pctComp   100
set summary   "Verify gtp-u PathMgmt 'inactivity-timer-duration' configuration and modification functionality on ePDG &
               Verify gtp-peer-status table should be present on ePDG network-context when the session is in idle state &
               Check GTP Peer status show zone default gateway gtp-peer-status"
set descr     "
1.  Remove and add again the gateways to clear gtp status table on MCC
2.  Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms
3.  Record the zone default gateway cluster-level gtp peer statistics
4.  Configure inactivity-timer-duration as 20 sec and bring up the session
5.  Verify that Subcriber is going IDLE after specified time
6.  Find the Tunnel endpoint IP addresses
7.  Verify that gtp-peer-status table is present with peer status as up on ePDG & PGW network contexts
8.  Record the zone default gateway cluster-level gtp peer statistics after the Session
9.  Verify if one Echo request and one Echo response is present
10. Verify the Stats on MCC with the PCAP"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Remove and add again the gateways to clear gtp status table on MCC" {
        
        ePDG:checkSessionState
        dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
        dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
        dut exec config "no zone default gateway epdg EPDG-1; commit"
        dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
        dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
        dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
        dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
        dut exec config "no zone default gateway pgw PGW-1; commit"    
        dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
        dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
        dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
        
    }
    
    runStep "Clear the zone default gateway cluster-level gtp peer statistics & configure gtp-echo-interval as 60000 ms" {
        
        set out [dut exec "show zone default gateway statistics cluster-level gtp peer | include \"gateway statistics cluster-level gtp peer\" | include [tb _ dut.chassisNumber]"]
        set lines [ePDG:numberOfLines $out]
        if { $lines == 0 } {
            puts "No GTP Peer is present"
        } elseif { $lines == 1 } {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
        } else {
            set peer1 [lrange $out 5 5]
            catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            set val 12
            for {set i 2 } { $i < [expr $lines + 1] } { incr i} {
                set peer [lrange $out $val $val]
                set val [expr $val + 7]
                catch {dut exec "zone default gateway statistics cluster-level gtp peer $peer [tb _ dut.chassisNumber] clear"}
            }
        }
        
    }
    
    runStep "Record the zone default gateway cluster-level gtp peer statistics" {
        
        set ePDGreqrece1 0
        set ePDGreqsent1 0
        set ePDGresrece1 0
        set ePDGressent1 0
        
        set PGWreqrece1 0
        set PGWreqsent1 0
        set PGWresrece1 0
        set PGWressent1 0
        
    }

    runStep "Configure inactivity-timer-duration as 20 sec and bring up the session" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 20"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 20; commit"                
            log.test "inactivity-timer-duration is configure as 20 sec"
        } else {
            error.an "Unable to configure inactivity-timer-duration as 20 sec"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
    }
    
    runStep "Verify that Subcriber is going IDLE after specified time" {
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1 } {
            log.test "ePDG Subscriber is in ACTIVE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        sleep 30
        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "idle"] == 1 } {
            log.test "ePDG Subscriber is in IDLE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is IDLE"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
    }
    
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
    }
    
    runStep "Verify that gtp-peer-status table is present with peer status as up on ePDG & PGW network contexts" {
        
        sleep 60
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        
        set epdgPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-EPDG-EPDG-1-$ip2 [tb _ dut.chassisNumber]"]
        set pgwPeer [dut exec "show zone default gateway statistics cluster-level gtp peer S2B-PGW-PGW-1-$ip1 [tb _ dut.chassisNumber]"]
        
        import_tshark_file
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-EPDG"        
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt >= 1 } {   
            log.test "gtp-peer-status table is present with peer status as up on ePDG network context"
        } else {
            error.an "gtp-peer-status table should be present with peer status as \"UP\" on ePDG network context"
        }
        
        set cnt 0
        dut exec "show zone default gateway gtp-peer-status network-context S2B-PGW"
        
        set processes [cmd_out . key-values]        
        foreach ck $processes {
            set state [cmd_out . values.$ck.PEERSTATE]
            if { $state == "up" } {
                set cnt [expr $cnt + 1]    
            }            
        }
        
        if { $cnt >= 1 } {   
            log.test "gtp-peer-status table is present with peer status as up on PGW network context"
        } else {
            error.an "gtp-peer-status table should be present with peer status as \"UP\" on PGW network context"
        }
        
    }
        
    runStep "Record the zone default gateway cluster-level gtp peer statistics after the Session" {
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $epdgPeer - ePDGreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $epdgPeer - ePDGreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $epdgPeer - ePDGresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $epdgPeer - ePDGressent2
        
        regexp.an -lineanchor {^\s*num-echo-requests-received\s+([0-9]+)$} $pgwPeer - PGWreqrece2
        regexp.an -lineanchor {^\s*num-echo-requests-sent\s+([0-9]+)$} $pgwPeer - PGWreqsent2
        regexp.an -lineanchor {^\s*num-echo-responses-received\s+([0-9]+)$} $pgwPeer - PGWresrece2
        regexp.an -lineanchor {^\s*num-echo-responses-sent\s+([0-9]+)$} $pgwPeer - PGWressent2              
        
    }        
    
    runStep "Verify if one Echo request and one Echo response is present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "ePDG is sending one Echo request and receiving one Echo response"
        } else {
            error.an "ePDG is sending $reqsts Echo requests and receiving $respns Echo responses"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Echo Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Echo Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "PGW is sending one Echo request and receiving one Echo response"
        } else {
            error.an "PGW is sending $reqsts Echo requests and receiving $respns Echo responses"
        }
		
    }
    
    runStep "Verify the Stats on MCC with the PCAP" {
        
        if { $ePDGreqrece2 == $ePDGreqrece1 + 1 && $ePDGreqsent2 == $ePDGreqsent1 + 1 && $ePDGresrece2 == $ePDGresrece1 + 1 && $ePDGressent2 == $ePDGressent1 + 1 } {             
            log.test "ePDG Peer stats Verified"
        } else {
            error.an "Unable to verify ePDG Peer stats"
        }
        
        if { $PGWreqrece2 == $PGWreqrece1 + 1 && $PGWreqsent2 == $PGWreqsent1 + 1 && $PGWresrece2 == $PGWresrece1 + 1 && $PGWressent2 == $PGWressent1 + 1 } {             
            log.test "PGW Peer stats Verified"
        } else {
            error.an "Unable to verify PGW Peer stats"
        }
        
    }
    
    
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway epdg EPDG-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"    
    dut exec config "zone default gateway epdg EPDG-1 admin-state disabled; commit"
    dut exec config "no zone default gateway epdg EPDG-1; commit"
    dut exec config "zone default gateway epdg EPDG-1 gateway-profile ePDG-PROFILE admin-state enabled home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 s2b-interface-gtpu-network-context S2B-EPDG fully-qualified-domain-name epdg.epc.mnc123.mcc456.pub.3gppnetwork.org s2b-gtpc-endpoint-params network-context S2B-EPDG loopback-ip S2B-EPDG-LB-V6; commit"    
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 apn-list apn2.epdg-access-pi.net; commit"
    dut exec config "zone default gateway epdg EPDG-1 swm-diameter-interface server-group-mapping 1 server-group SWM-SERVER-1 mapped-apn-name apn.epdg-access-pi.net; commit"         
    dut exec config "zone default gateway pgw PGW-1; no gtpu-loopback-list; commit"         
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW; no key key1; commit"    
    dut exec config "zone default gateway pgw PGW-1 admin-state disabled; commit"    
    dut exec config "no zone default gateway pgw PGW-1; commit"    
    dut exec config "zone default gateway pgw PGW-1 gateway-profile PGW-PROFILE s5-s8-interface-network-context S2B-PGW home-plmnid-list HOME-PLMNID-LIST-1 roaming-plmnid-list ROAM-PLMNID-LIST-1 admin-state enabled gtpc-endpoint-params network-context S2B-PGW loopback-ip PGW-LB-V6; commit"    
    dut exec config "zone default gateway pgw PGW-1 apn-list apn.epdg-access-pi.net; zone default gateway pgw PGW-1 apn-list apn2.epdg-access-pi.net; commit"    
    dut exec config "workflow subscriber-analyzer SUB-ANA-PGW key key1 pgw-name PGW-1; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 300; commit"
    sleep 60
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778978
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/21/2016
set pctComp   100
set summary   "	Verify gtp-u PathMgmt 'idle-session-clearing-state' configuration and modification functionality on ePDG &
               	Verify gtp-u PathMgmt 'idle-timer-duration' configuration and modification functionality on ePDG"
set descr     "
1.  Configure configure idle-session-clearing-state as enabled and bring up the session
2.  Verify that Subcriber is going IDLE after specified time
3.  Find the Tunnel endpoint IP addresses
4.  Check if no any session/tunnel is active/present
5.  Verify ePDG is sending Delete Session Request to PGW with corresponding TEID
6.  Verify PGW is sending Delete Session Response to ePDG with corresponding TEID
7.  Verify the TEIDs
8.  Verify if only one Delete session request and delete session response is present"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
        
    runStep "Configure configure idle-session-clearing-state as enabled and bring up the session" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 20"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 20; commit"                
            log.test "inactivity-timer-duration is configure as 20 sec"
        } else {
            error.an "Unable to configure inactivity-timer-duration as 20 sec"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE idle-session-clearing-state enabled"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-session-clearing-state enabled; commit"                
            log.test "idle-session-clearing-state is configure as enabled"
        } else {
            error.an "Unable to configure idle-session-clearing-state as enabled"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE idle-timer-duration 20"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-timer-duration 20; commit"                
            log.test "idle-timer-duration is configure as 20 sec"
        } else {
            error.an "Unable to configure idle-timer-duration as 20 sec"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
    }
    
    runStep "Verify that Subcriber is going IDLE after specified time" {
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1 } {
            log.test "ePDG Subscriber is in ACTIVE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        sleep 30        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "idle"] == 1 } {
            log.test "ePDG Subscriber is in IDLE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is IDLE"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-value\s+([0-9]+)$} $sessionInfo - teidOut] } {
            log.test "network-out-control-teid-value: $teidOut"
        } else {
            error.an "Unable to find Network-out-control-teid-value"
        }
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-value\s+([0-9]+)$} $sessionInfo - teidIn] } {
            log.test "network-in-control-teid-value: $teidIn"
        } else {
            error.an "Unable to find Network-in-control-teid-value"
        }
        
    }
    
    runStep "Check if no any session/tunnel is active/present" {
        
        sleep 20
        
        set out [dut exec "show subscriber summary gateway-type epdg"]
        
        if { [regexp.an "No entries found." $out] } {
            log.test "No any epdg session found"
        } else {
            error.an "Found epdg session"
        }
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 0 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 0} {
            log.test "No any IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 0"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
		
    }
    
     runStep "Verify ePDG is sending Delete Session Request to PGW with corresponding TEID" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2' | grep -e \"Delete Session Request\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gtpv2.message_type\" showname=\"Message Type: Delete Session Request} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.teid\" showname=\"Tunnel Endpoint Identifier: ([0-9a-zA-Z]+) \(([0-9]+)\)\"} $packetInfo - hexval teid1] == 1 } {             
            log.test "ePDG is sending Delete Session Request to PGW with TEID : $teid1"
        } else {
            error.an "Unable to find Delete Session Request from ePDG to PGW"
        }
        
    }
    
    runStep "Verify PGW is sending Delete Session Response to ePDG with corresponding TEID" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1' | grep -e \"Delete Session Response\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gtpv2.message_type\" showname=\"Message Type: Delete Session Response} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.teid\" showname=\"Tunnel Endpoint Identifier: ([0-9a-zA-Z]+) \(([0-9]+)\)\"} $packetInfo - hexval teid2] == 1 &&
             [regexp.an {<field name=\"gtpv2.ie_type\" showname=\"IE Type: Cause \(2\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.cause\" showname=\"Cause: Request accepted \(16\)\"} $packetInfo] == 1 } {             
            log.test "PGW is sending Delete Session Response to ePDG with TEID : $teid2"
        } else {
            error.an "Unable to find Delete Session Response from PGW to ePDG"
        }
        
    }
    
    runStep "Verify the TEIDs" {
        
        if { $teidOut == $teid1 && $teidIn == $teid2 } {
            log.test "TEIDs in DSR match with the one on MCC"
        } else {
            error.an "TEID in DSR do not match with the one on MCC"
        }
		
    }
    
    runStep "Verify if only one Delete session request and delete session response is present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Session Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "Only one Delete session request and delete session response is present"
        } else {
            error.an "More than one Delete session request and delete session response is present ; Expected is only one Transaction"
        }
		
    }    
       
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true; commit"                
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"         
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 300; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-session-clearing-state enabled; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-timer-duration 86400; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778976
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/21/2016
set pctComp   100
set summary   "	Verify gtp-u PathMgmt 'idle-session-clearing-state' configuration and modification functionality on ePDG"               	
set descr     "
1.  Configure configure idle-session-clearing-state as enabled and bring up the session
2.  Verify that Subcriber is going IDLE after specified time
3.  Find the Tunnel endpoint IP addresses
4.  Check if one session/tunnel is active/present
5.  Verify if only no Delete session request and delete session response is present"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
        
    runStep "Configure configure idle-session-clearing-state as enabled and bring up the session" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 20"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 20; commit"                
            log.test "inactivity-timer-duration is configure as 20 sec"
        } else {
            error.an "Unable to configure inactivity-timer-duration as 20 sec"
        }        
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE idle-timer-duration 20"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-timer-duration 20; commit"                
            log.test "idle-timer-duration is configure as 20 sec"
        } else {
            error.an "Unable to configure idle-timer-duration as 20 sec"
        }
                
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE idle-session-clearing-state disabled"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-session-clearing-state disabled; commit"                
            log.test "idle-session-clearing-state is configure as disabled"
        } else {
            error.an "Unable to configure idle-session-clearing-state as disabled"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
    }
    
    runStep "Verify that Subcriber is going IDLE after specified time" {
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1 } {
            log.test "ePDG Subscriber is in ACTIVE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        sleep 30        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "idle"] == 1 } {
            log.test "ePDG Subscriber is in IDLE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is IDLE"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-value\s+([0-9]+)$} $sessionInfo - teidOut] } {
            log.test "network-out-control-teid-value: $teidOut"
        } else {
            error.an "Unable to find Network-out-control-teid-value"
        }
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-value\s+([0-9]+)$} $sessionInfo - teidIn] } {
            log.test "network-in-control-teid-value: $teidIn"
        } else {
            error.an "Unable to find Network-in-control-teid-value"
        }
        
    }
    
    runStep "Check if one session/tunnel is active/present" {
        
        sleep 20
        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "idle"] == 1 } {
            log.test "ePDG Subscriber is in IDLE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is IDLE"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 1 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 1 } {
            log.test "1 IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 1"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
		
    }
    
    runStep "Verify if no Delete session/bearer request and delete session/bearer response is present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Session Response\" | wc -l"]
        
        if { $reqsts == 0 && $respns == 0 } {
            log.test "No Delete session request and delete session response is present"
        } else {
            error.an "Delete session request and delete session response is present ; Expected is None"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Bearer Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Bearer Response\" | wc -l"] 
        
        if { $reqsts == 0 && $respns == 0 } {
            log.test "No Delete Bearer request and delete Bearer response is present"
        } else {
            error.an "Delete Bearer request and delete Bearer response is present ; Expected is None"
        }
		
    }    
       
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE initiate-echo-requests true; commit"                
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE gtp-echo-interval 60000; commit"         
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE inactivity-timer-duration 300; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-session-clearing-state enabled; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE idle-timer-duration 86400; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778979
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/26/2016
set pctComp   100
set summary   "Verify gtp-u PathMgmt 'reject-gtpc-messages-from-unconfigured-peers' configuration and modification functionality on ePDG"
set descr     "
1.  Configure reject-gtpc-messages-from-unconfigured-peers as false
2.  Capture the packets on S2B interface and start the session
3.  Get the Source and Destination IP addresses of the GTP-C messages
4.  Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages
5.  Configure reject-gtpc-messages-from-unconfigured-peers as true
6.  Capture the packets on S2B interface and Bring up the session and check if it fails
7.  Verify if No any GTPv2 messages are present
8.  Configure reject-gtpc-messages-from-unconfigured-peers as true
9.  Get the Source and Destination IP addresses of the GTP-C messages
10. Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Configure reject-gtpc-messages-from-unconfigured-peers as false" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers false"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers false; commit"                
            log.test "reject-gtpc-messages-from-unconfigured-peers is configure as false"
        } else {
            error.an "Unable to configure reject-gtpc-messages-from-unconfigured-peers as false"
        }
       
    }
    
    runStep "Capture the packets on S2B interface and start the session" {
                
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
            
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_pgw
        
        if { [string match $ip1 $ip_epdg] == 1 && [string match $ip2 $ip_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet
            Verified the gtp-u PathMgmt \'reject-gtpc-messages-from-unconfigured-peers\' configuration and modification functionality on ePDG when it is set to false"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet
            Unable to Verify gtp-u PathMgmt \'reject-gtpc-messages-from-unconfigured-peers\' configuration and modification functionality on ePDG"
        }
        
    }
       
    runStep "Configure reject-gtpc-messages-from-unconfigured-peers as true" {
        
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"        
        ePDG:clear_tshark_data
        
        dut exec config "zone default gateway epdg EPDG-1; no gtp-peer-list; commit"
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers true"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers true; commit"                
            log.test "reject-gtpc-messages-from-unconfigured-peers is configure as true"
        } else {
            error.an "Unable to configure reject-gtpc-messages-from-unconfigured-peers as true"
        }
         
    }
    
    runStep "Capture the packets on S2B interface and Bring up the session and check if it fails" {
                
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        catch [ue exec "ipsec restart"]        
        ue closeCli
        ue initCli -4 true
        
        catch {ue exec "ipsec up epdg" -timeout 200} result
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
        if { [regexp.an {\s*received INTERNAL_ADDRESS_FAILURE notify, no CHILD_SA built\s+failed to establish CHILD_SA, keeping IKE_SA\s+establishing connection 'epdg' failed} $result] == 1 } {
            log.test "UE reports: connection 'epdg' Failed"
        } else {
            error.an "Logs do not have IPSec Fail message. Expacted is : \"establishing connection 'epdg' failed\""
        }
        
    }
    
    runStep "Verify if No any GTPv2 messages are present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Create Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Create Session Response\" | wc -l"]        
        
        if { $reqsts == 0 && $respns ==   0 } {
            log.test "ePDG is not sending any Create Session Request and PGW is not sending any Create Session Response"
        } else {
            error.an "ePDG is sending $reqsts Create Session requests and PGW is receiving $respns Create Session responses"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Create Bearer Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Create Bearer Response\" | wc -l"]        
        
        if { $reqsts == 0 && $respns ==   0 } {
            log.test "PGW is not sending any Create Bearer Request and ePDG is not sending any Create Bearer Response"
        } else {
            error.an "PGW is sending $reqsts Create Session requests and ePDG is receiving $respns Create Session responses"
        }
		
    }
    
    runStep "Configure reject-gtpc-messages-from-unconfigured-peers as true" {
        
        ue exec "ipsec restart"
        dut exec "subscriber clear-local"
        ePDG:clear_tshark_data
        
        dut exec config "zone default gateway epdg EPDG-1; gtp-peer-list EPDGV6; commit"
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers true"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers true; commit"                
            log.test "reject-gtpc-messages-from-unconfigured-peers is configure as true"
        } else {
            error.an "Unable to configure reject-gtpc-messages-from-unconfigured-peers as true"
        }
         
    }
    
    runStep "Capture the packets on S2B interface and start the session" {
             
		dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsec_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
         
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
    }
    
    runStep "Get the Source and Destination IP addresses of the GTP-C messages" {
        
        set out [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$3}'"]
        set ip1 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Request' | awk '{print \$5}'"]
        set ip2 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$3}'"]
        set ip3 [ePDG:store_last_line $out1]
        
        set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2' | grep 'Create Session Response' | awk '{print \$5}'"]
        set ip4 [ePDG:store_last_line $out1]
        
        if { [string match $ip1 $ip4] == 1 && [string match $ip2 $ip3] == 1 } {
            log.test "Valid Session Request and Response found"
        } else {
            error.an "Source & Destination IP address mismatch for session request and response"
        }
        
    }
    
    runStep "Get the Tunnel Endpoint IP addresses from MCC and match it with the Source and Destination IP addresses of the GTP-C messages" {
                
        dut exec "show subscriber summary gateway-type epdg"
        
        if { ![string is integer -strict [set id_ [cmd_out . key-values]]] } {
            error.an "Expected one epdg session"
        } else {
            log.test "Found epdg session with id: $id_"
        }

        set out [dut exec "show subscriber pdn-session $id_"]
        
        regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_epdg
        regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $out - ip_pgw
        
        if { [string match $ip1 $ip_epdg] == 1 && [string match $ip2 $ip_pgw] == 1 } {
            log.test "Tunnel Endpoint IPv6 addresses match with the Source and Dest. IPv6 addresses for GTP-C packet
            Verified the gtp-u PathMgmt \'reject-gtpc-messages-from-unconfigured-peers\' configuration and modification functionality on ePDG when it is set to false"
        } else {
            error.an "Tunnel Endpoint IPv6 addresses do not match with the Source and Dest. IPv6 addresses for GTP-C packet
            Unable to Verify gtp-u PathMgmt \'reject-gtpc-messages-from-unconfigured-peers\' configuration and modification functionality on ePDG"
        }
        
    }
    
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE reject-gtpc-messages-from-unconfigured-peers false; commit"
    dut exec config "zone default gateway epdg EPDG-1; no gtp-peer-list; commit"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778950
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/26/2016
set pctComp   100
set summary   "Verify GTPv2 peer list configuration, Modification and deletion"
set descr     "Verify GTPv2 peer list configuration, Modification and deletion"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
    
    runStep "Verify GTPv2 peer list configuration, Modification and deletion" {
        
        if { [dut . configurator testCmd "zone default gateway gtp-peer EPDG2V6 gtp-version gtpv2 is-present-in-local-PLMN true network-context S2B-EPDG peer-ip-address 2001:470:8865:4089:89::[format %x [tb _ dut.chassisNumber]]"] == 1 } {            
            dut exec config "zone default gateway gtp-peer EPDG2V6 gtp-version gtpv2 is-present-in-local-PLMN true network-context S2B-EPDG peer-ip-address 2001:470:8865:4089:89::[format %x [tb _ dut.chassisNumber]]; commit"                
            log.test "New GTP-PEER EPDG2V6 is configured"
        } else {
            error.an "Unable to configure New GTP-PEER EPDG2V6"
        }
        
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 gtp-peer-list EPDGV6"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 gtp-peer-list EPDGV6; commit"                
            log.test "GTP-PEER EPDGV6 is associated with epdg object"
        } else {
            error.an "Unable to associate GTP-PEER EPDGV6 with epdg object"
        }
        
        if { [dut . configurator testCmd "zone default gateway epdg EPDG-1 gtp-peer-list EPDG2V6"] == 1 } {            
            dut exec config "zone default gateway epdg EPDG-1 gtp-peer-list EPDG2V6; commit"                
            log.test "GTP-PEER EPDG2V6 is associated with epdg object"
        } else {
            error.an "Unable to associate GTP-PEER EPDG2V6 with epdg object"
        }
        
        set out [dut exec "show running-config zone default gateway epdg gtp-peer-list"]
        
        regexp.an -lineanchor {^\s*gtp-peer-list\s+([-0-9a-zA-Z_]+)$} $out - peer1
        regexp.an -lineanchor -all {^\s*gtp-peer-list\s+([-0-9a-zA-Z_]+)$} $out - peer2
        
        if { [string match $peer1 "EPDG2V6"] == 1 && [string match $peer2 "EPDGV6"] == 1 } {
            log.test "Peers Configured Successfilly - Verified"
        } else {
            error.an "Unable to verify the Configured Peers"
        }
               
        catch {dut exec config "no zone default gateway gtp-peer EPDG2V6; commit"} result                
        
        if { [regexp.an ": illegal reference 'zone default gateway epdg EPDG-1 gtp-peer-list EPDG2V6 name'" $result] } {
            log.test "GTP-PEER deletion not allowed when it is associated with ePDG gateway object - Functionality Verified"
        } else {
            error.an "GTP-PEER deletion not allowed when it is associated with ePDG gateway object - Unable to verify this Functionality"
        }
        
        catch {dut exec config "zone default gateway gtp-peer EPDGV6; is-present-in-local-PLMN false; commit"} result                
        
        if { [regexp.an ": 'zone default gateway gtp-peer': GTP Peer modification is not allowed.  Please delete and re-add instead." $result] } {
            log.test "GTP-PEER Modification not allowed when it is associated with ePDG gateway object - Functionality Verified"
        } else {
            error.an "GTP-PEER Modification not allowed when it is associated with ePDG gateway object - Unable to verify this Functionality"
        }
        
        if { [dut . configurator testCmd "no zone default gateway epdg EPDG-1 gtp-peer-list EPDGV6"] == 1 } {            
            dut exec config "no zone default gateway epdg EPDG-1 gtp-peer-list EPDGV6; commit"                
            log.test "GTP-PEER EPDGV6 is removed from the epdg object"
        } else {
            error.an "Unable to remove GTP-PEER EPDGV6 from epdg object"
        }
        
        if { [dut . configurator testCmd "no zone default gateway epdg EPDG-1 gtp-peer-list EPDG2V6"] == 1 } {            
            dut exec config "no zone default gateway epdg EPDG-1 gtp-peer-list EPDG2V6; commit"                
            log.test "GTP-PEER EPDG2V6 is removed from the epdg object"
        } else {
            error.an "Unable to remove GTP-PEER EPDG2V6 from epdg object"
        }
        
        set out [dut exec "show running-config zone default gateway epdg gtp-peer-list"]
        
        if { [regexp.an "No entries found." $out] } {
            log.test "Peers removed Successfilly from epdg object- Verified"
        } else {
            error.an "Unable to verify the removed Peers from epdg object"
        }
        
        if { [dut . configurator testCmd "no zone default gateway gtp-peer EPDG2V6"] == 1 } {            
            dut exec config "no zone default gateway gtp-peer EPDG2V6; commit"                
            log.test "GTP-PEER EPDG2V6 is Deleted Successfully"
        } else {
            error.an "Unable to Delete the GTP-PEER EPDG2V6"
        }
        
        set out [dut exec " show running-config zone default gateway gtp-peer"]
        
        if { [regexp.an "EPDG2V6" $out] == 0} {
            log.test "GTP-PEER EPDG2V6 is Deleted Successfully- Verified"
        } else {
            error.an "Unable to Delete the GTP-PEER EPDG2V6"
        }
       
    }
    
} {
    # Cleanup
    dut exec config "no zone default gateway epdg EPDG-1 gtp-peer-list EPDGV6; commit"                
    dut exec config "no zone default gateway epdg EPDG-1 gtp-peer-list EPDG2V6; commit"
    dut exec config "no zone default gateway gtp-peer EPDG2V6; commit"        
    dut exec config "zone default gateway epdg EPDG-1; no gtp-peer-list; commit"
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852680
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/27/2016
set pctComp   100
set summary   "	Verify gtp-u PathMgmt 'session-max-timer-duration' configuration and modification functionality on ePDG &
               	Verify gtp-u PathMgmt 'session-max-clearing-state' configuration and modification functionality on ePDG"
set descr     "
1.  Configure configure session-max-clearing-state as enabled with 2 mins duration and bring up the session
2.  Find the Tunnel endpoint IP addresses
3.  Check if no any session/tunnel is active/present
4.  Verify ePDG is sending Delete Session Request to PGW with corresponding TEID
5.  Verify PGW is sending Delete Session Response to ePDG with corresponding TEID
6.  Verify the TEIDs
7.  Verify if only one Delete session request and delete session response is present"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
        
    runStep "Configure configure session-max-clearing-state as enabled 2 mins duration and bring up the session" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE session-max-clearing-state enabled"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE session-max-clearing-state enabled; commit"                
            log.test "session-max-clearing-state is configure as enabled"
        } else {
            error.an "Unable to configure session-max-clearing-state as enabled"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE session-max-timer-duration 2"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE session-max-timer-duration 2; commit"                
            log.test "session-max-timer-duration is configure as 2 mins"
        } else {
            error.an "Unable to configure session-max-timer-duration as 2 mins"
        }
       
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-value\s+([0-9]+)$} $sessionInfo - teidOut] } {
            log.test "network-out-control-teid-value: $teidOut"
        } else {
            error.an "Unable to find Network-out-control-teid-value"
        }
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-value\s+([0-9]+)$} $sessionInfo - teidIn] } {
            log.test "network-in-control-teid-value: $teidIn"
        } else {
            error.an "Unable to find Network-in-control-teid-value"
        }
        
    }
    
    runStep "Check if no any session/tunnel is active/present" {
        
        sleep 130
        
        set out [dut exec "show subscriber summary gateway-type epdg"]
        
        if { [regexp.an "No entries found." $out] } {
            log.test "No any epdg session found"
        } else {
            error.an "Found epdg session"
        }
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 0 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 0} {
            log.test "No any IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 0"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
		
    }
    
     runStep "Verify ePDG is sending Delete Session Request to PGW with corresponding TEID" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2' | grep -e \"Delete Session Request\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gtpv2.message_type\" showname=\"Message Type: Delete Session Request} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.teid\" showname=\"Tunnel Endpoint Identifier: ([0-9a-zA-Z]+) \(([0-9]+)\)\"} $packetInfo - hexval teid1] == 1 } {             
            log.test "ePDG is sending Delete Session Request to PGW with TEID : $teid1"
        } else {
            error.an "Unable to find Delete Session Request from ePDG to PGW"
        }
        
    }
    
    runStep "Verify PGW is sending Delete Session Response to ePDG with corresponding TEID" {
        
        tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'"
		set out1 [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1' | grep -e \"Delete Session Response\" | awk  '{print \$1}' | sed -n '1p'"]        
		set frameNumber [ePDG:store_last_line $out1]
		
		set packetInfo [tshark exec "tshark -r /tmp/umakant -Y frame.number==$frameNumber -T pdml"]
        
        if { [regexp.an {<field name=\"gtpv2.message_type\" showname=\"Message Type: Delete Session Response} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.teid\" showname=\"Tunnel Endpoint Identifier: ([0-9a-zA-Z]+) \(([0-9]+)\)\"} $packetInfo - hexval teid2] == 1 &&
             [regexp.an {<field name=\"gtpv2.ie_type\" showname=\"IE Type: Cause \(2\)\"} $packetInfo] == 1 &&
             [regexp.an {<field name=\"gtpv2.cause\" showname=\"Cause: Request accepted \(16\)\"} $packetInfo] == 1 } {             
            log.test "PGW is sending Delete Session Response to ePDG with TEID : $teid2"
        } else {
            error.an "Unable to find Delete Session Response from PGW to ePDG"
        }
        
    }
    
    runStep "Verify the TEIDs" {
        
        if { $teidOut == $teid1 && $teidIn == $teid2 } {
            log.test "TEIDs in DSR match with the one on MCC"
        } else {
            error.an "TEID in DSR do not match with the one on MCC"
        }
		
    }
    
    runStep "Verify if only one Delete session request and delete session response is present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Session Response\" | wc -l"]        
        
        if { $reqsts == 1 && $respns == 1 } {
            log.test "Only one Delete session request and delete session response is present"
        } else {
            error.an "More than one Delete session request and delete session response is present ; Expected is only one Transaction"
        }
		
    }    
       
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE session-max-clearing-state disabled; commit"               
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C778977
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/27/2016
set pctComp   100
set summary   "	Verify gtp-u PathMgmt 'session-max-clearing-state' configuration and modification functionality on ePDG"               	
set descr     "
1.  Configure configure idle-session-clearing-state as enabled and bring up the session
2.  Find the Tunnel endpoint IP addresses
3.  Check if one session/tunnel is active/present
4.  Verify if only no Delete session request and delete session response is present"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {
        
    runStep "Configure configure session-max-clearing-state as Disabled and bring up the session" {
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE session-max-clearing-state disabled"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE session-max-clearing-state disabled; commit"                
            log.test "session-max-clearing-state is configure as enabled"
        } else {
            error.an "Unable to configure session-max-clearing-state as enabled"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        array set ipsec [ePDG:start_ipsecv4_session]
		ePDG:ue_ping_os $ipsec(ueIp4)
        
        set sessionInfo [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid)"]
        
    }
    
    runStep "Find the Tunnel endpoint IP addresses" {
    
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip1] } {
            log.test "ePDG Loopback ip-address: $ip1"
        } else {
            error.an "Failed to retrieve ePDG Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-v6-ip-address\s+([0-9:a-z]+)$} $sessionInfo - ip2] } {
            log.test "PGW Loopback ip-address: $ip2"
        } else {
            error.an "Failed to retrieve PGW Loopback ip-address"
        }
        
        if { [regexp.an -lineanchor {^\s*network-out-control-teid-value\s+([0-9]+)$} $sessionInfo - teidOut] } {
            log.test "network-out-control-teid-value: $teidOut"
        } else {
            error.an "Unable to find Network-out-control-teid-value"
        }
        
        if { [regexp.an -lineanchor {^\s*network-in-control-teid-value\s+([0-9]+)$} $sessionInfo - teidIn] } {
            log.test "network-in-control-teid-value: $teidIn"
        } else {
            error.an "Unable to find Network-in-control-teid-value"
        }
        
    }
    
    runStep "Check if one session/tunnel is active/present" {
        
        sleep 130
        
        dut exec "show subscriber summary gateway-type epdg"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1 } {
            log.test "ePDG Subscriber is in ACTIVE State"
        } else {
            error.an "ePDG Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        dut exec "show subscriber summary gateway-type pgw"

        if { [string match [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] "active"] == 1} {
            log.test "PGW Subscriber is in ACTIVE State"
        } else {
            error.an "PGW Subscriber is in [cmd_out . values.[cmd_out . key-values].SUBSCRIBERACTIVITYSTATE] State ; Expected is ACTIVE"
        }
        
        dut exec "show security statistics network-context SWU"
        
        if { [set iketun [cmd_out . values.SWU.CURRENTIKETUNNELS]] == 1 && [set ipsectun [cmd_out . values.SWU.CURRENTIPSECTUNNELS]] == 1 } {
            log.test "1 IKE & IPSec tunnel/s is/are Present"
        } else {
            error.an "($iketun) IKE-Tunnel/s and ($ipsectun) IPSec-Tunnel/s is/are present ; Expected is 1"
        }
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
		
    }
    
    runStep "Verify if no Delete session/bearer request and delete session/bearer response is present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Session Response\" | wc -l"]
        
        if { $reqsts == 0 && $respns == 0 } {
            log.test "No Delete session request and delete session response is present"
        } else {
            error.an "Delete session request and delete session response is present ; Expected is None"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip2 && ipv6.dst==$ip1'  | grep -e \"Delete Bearer Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2 and ipv6.src==$ip1 && ipv6.dst==$ip2'  | grep -e \"Delete Bearer Response\" | wc -l"] 
        
        if { $reqsts == 0 && $respns == 0 } {
            log.test "No Delete Bearer request and delete Bearer response is present"
        } else {
            error.an "Delete Bearer request and delete Bearer response is present ; Expected is None"
        }
		
    }    
       
} {
    # Cleanup
    ePDG:clear_tshark_data
    ePDG:checkSessionState
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE session-max-clearing-state disabled; commit"      
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852692
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is in HPLMN and allowed-plmnid is set to home"               	
set descr     "
1.  Configure allowed-plmnid as home-list
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as home-list" {

        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"    
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-list"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-list; commit"                
            log.test "allowed-plmnid is configure as home-list"
        } else {
            error.an "Unable to configure allowed-plmnid as home-list"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "home"] == 1 } {
            log.test "Subscriber is in HPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: home"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852695
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is in HPLMN and allowed-plmnid is set to any"               	
set descr     "
1.  Configure allowed-plmnid as any
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as any" {

        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"    
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
            log.test "allowed-plmnid is configure as any"
        } else {
            error.an "Unable to configure allowed-plmnid as any"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "home"] == 1 } {
            log.test "Subscriber is in HPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: home"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852698
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is in HPLMN and allowed-plmnid is set to home-or-roaming-list"               	
set descr     "
1.  Configure allowed-plmnid as home-or-roaming-list
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as home-or-roaming-list" {

        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"    
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-or-roaming-list"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-or-roaming-list; commit"                
            log.test "allowed-plmnid is configure as home-or-roaming-list"
        } else {
            error.an "Unable to configure allowed-plmnid as home-or-roaming-list"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "home"] == 1 } {
            log.test "Subscriber is in HPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: home"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852693
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is in VPLMN and allowed-plmnid is set to home"               	
set descr     "
1.  Configure allowed-plmnid as home-list
2.  Try to Bring up the session and check if it fails
3.  Verify if No any GTPv2 messages are present"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as home-list" {

        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1 plmnid 456123; commit"            
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-list"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-list; commit"                
            log.test "allowed-plmnid is configure as home-list"
        } else {
            error.an "Unable to configure allowed-plmnid as home-list"
        }
        
    }
    
    runStep "Try to Bring up the session and check if it fails" {
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 startcapture count 10000 duration 600 file-name umakant"
		
        catch [ue exec "ipsec restart"]        
        ue closeCli
        ue initCli -4 true
        
        catch {ue exec "ipsec up epdg" -timeout 200} result
        
        dut exec "network-context S2B-EPDG ip-interface S2B-EPDG-5-1 stopcapture"
        import_tshark_file
        
        if { [regexp.an {\s*received INTERNAL_ADDRESS_FAILURE notify, no CHILD_SA built\s+failed to establish CHILD_SA, keeping IKE_SA\s+establishing connection 'epdg' failed} $result] == 1 } {
            log.test "UE reports: connection 'epdg' Failed"
        } else {
            error.an "Logs do not have IPSec Fail message. Expacted is : \"establishing connection 'epdg' failed\""
        }
        
    }
    
    runStep "Verify if No any GTPv2 messages are present" {
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'  | grep -e \"Create Session Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'  | grep -e \"Create Session Response\" | wc -l"]        
        
        if { $reqsts == 0 && $respns ==   0 } {
            log.test "ePDG is not sending any Create Session Request and PGW is not sending any Create Session Response"
        } else {
            error.an "ePDG is sending $reqsts Create Session requests and PGW is receiving $respns Create Session responses"
        }
        
        set reqsts [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'  | grep -e \"Create Bearer Request\" | wc -l"]        
        set respns [tshark exec "tshark -r /tmp/umakant -Y 'gtpv2'  | grep -e \"Create Bearer Response\" | wc -l"]        
        
        if { $reqsts == 0 && $respns ==   0 } {
            log.test "PGW is not sending any Create Bearer Request and ePDG is not sending any Create Bearer Response"
        } else {
            error.an "PGW is sending $reqsts Create Session requests and ePDG is receiving $respns Create Session responses"
        }
		
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852696
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is in VPLMN and allowed-plmnid is set to any"               	
set descr     "
1.  Configure allowed-plmnid as any
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as any" {

        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1 plmnid 456123; commit"  
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
            log.test "allowed-plmnid is configure as any"
        } else {
            error.an "Unable to configure allowed-plmnid as any"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "visiting"] == 1 } {
            log.test "Subscriber is in VPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: visiting"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852699
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is in VPLMN and allowed-plmnid is set to home-or-roaming-list"               	
set descr     "
1.  Configure allowed-plmnid as home-or-roaming-list
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure allowed-plmnid as home-or-roaming-list" {

        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1 plmnid 456123; commit"  
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-or-roaming-list"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid home-or-roaming-list; commit"                
            log.test "allowed-plmnid is configure as home-or-roaming-list"
        } else {
            error.an "Unable to configure allowed-plmnid as home-or-roaming-list"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "visiting"] == 1 } {
            log.test "Subscriber is in VPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: visiting"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852694
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is neither in HPLMN nor in VPLMN and non-matching-plmnid is set to home"               	
set descr     "
1.  Configure non-matching-plmnid as home
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure non-matching-plmnid as home" {

        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1; no plmnid 456123; commit"    
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE non-matching-plmnid home"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE non-matching-plmnid home; commit"                
            log.test "non-matching-plmnid is configure as home"
        } else {
            error.an "Unable to configure non-matching-plmnid as home"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
            log.test "allowed-plmnid is configure as any"
        } else {
            error.an "Unable to configure allowed-plmnid as any"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "home"] == 1 } {
            log.test "Subscriber is in HPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: home"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE non-matching-plmnid visiting; commit"                
    ePDG:mcc_crash_checkup
}

# ==============================================================
set id        ePDG:section1:EPDG:C852697
set category  "functional"
set ftrId     "infrastructure"
set atrId     "None"
set atrDesc   "None"
set comDate   12/28/2016
set pctComp   100
set summary   "Verify the Session if Subscriber is neither in HPLMN nor in VPLMN and non-matching-plmnid is set to visiting"               	
set descr     "
1.  Configure non-matching-plmnid as visiting
2.  Bring up the session and check the Data; Verify the Subscriber Location & PLMNID"

runTest $id $filename $category $ftrId $atrId $atrDesc $comDate $pctComp $summary $descr {

    runStep "Configure non-matching-plmnid as visiting" {

        dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
        dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1; no plmnid 456123; commit"    
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE non-matching-plmnid visiting"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE non-matching-plmnid visiting; commit"                
            log.test "non-matching-plmnid is configure as visiting"
        } else {
            error.an "Unable to configure non-matching-plmnid as visiting"
        }
        
        if { [dut . configurator testCmd "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any"] == 1 } {            
            dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"                
            log.test "allowed-plmnid is configure as any"
        } else {
            error.an "Unable to configure allowed-plmnid as any"
        }
        
    }
    
    runStep "Bring up the session and check the Data; Verify the Subscriber Location" {
        
        array set ipsec [ePDG:start_ipsec_session]
        ePDG:ue_ping_os $ipsec(ueIp4)
        ePDG:ue_ping_os2 $ipsec(ueIp4)
        ePDG:ue_tcp_os $ipsec(ueIp4)
        
        dut exec "show subscriber summary gateway-type epdg"
		
		if { [string match [set loc [cmd_out .  values.[cmd_out . key-values].SUBSCRIBERLOCATIONSTATE]] "visiting"] == 1 } {
            log.test "Subscriber is in VPLMN"
        } else {
            error.an "Subscriber is in $loc. Expected is in: visiting"
        }
        
        set out [dut exec "show subscriber pdn-session $ipsec(epdg_sessionid) plmn-for-pgw-dns"]
		
		if { [regexp.an -lineanchor {^\s*plmn-for-pgw-dns\s+([0-9]+)$} $out - plmnid] && $plmnid == "456123" } {
            log.test "Subscriber Location and PLMNID Verified"
        } else {
            error.an "Failed to Verify Subscriber Location and PLMNID"
        }
        
    }
    
} {
    # Cleanup
    ePDG:checkSessionState
    dut exec config "service-construct plmnid-list ROAM-PLMNID-LIST-1; no plmnid 456123; commit"    
    dut exec config "service-construct plmnid-list HOME-PLMNID-LIST-1 plmnid 456123; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE allowed-plmnid any; commit"
    dut exec config "zone default gateway profile gateway-common ePDG-PROFILE non-matching-plmnid visiting; commit"                
    ePDG:mcc_crash_checkup
}

catch {itcl::delete object tb}
