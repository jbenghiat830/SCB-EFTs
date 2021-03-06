<#-- Author: Michael Wang | mwang@netsuite.com -->
<#-- Bank Format: SCB-iPaymentCSV -->
<#-- format specific processing -->
<#assign overflowAddr = "">
<#function buildEntityBillingAddress entity>
    <#assign address = "">
    <#if entity.billaddress1?has_content >
        <#if (entity.billaddress1?length > 35) >
        	<#assign address = entity.billaddress1?substring(0, 35)>
        	<#assign overflowAddr = entity.billaddress1?substring(35)>
        <#else>
        	<#assign address = entity.billaddress1 >
        </#if>
    <#elseif entity.shipaddress1?has_content >
        <#if (entity.shipaddress1?length > 35) >
        	<#assign address = entity.shipaddress1?substring(0, 35)>
        	<#assign overflowAddr = entity.shipaddress1?substring(35)>
        <#else>
        	<#assign address = entity.shipaddress1 >
        </#if>
    <#elseif entity.address1?has_content >
        <#if (entity.address1?length > 35) >
        	<#assign address = entity.address1?substring(0, 35)>
        	<#assign overflowAddr = entity.address1?substring(35)>
        <#else>
        	<#assign address = entity.address1 >
        </#if>
    </#if>
    <#return address>
</#function>

<#function trimBankCountry str>
	<#if str?ends_with(" - US")>
		<#return str?substring(0, str?length-5)>
	</#if>
	
	<#if str?ends_with("-US")>
		<#return str?substring(0, str?length-3)>
	</#if>
	
	<#if str?ends_with("- US") || str?ends_with(" -US")>
		<#return str?substring(0, str?length-4)>
	</#if>
</#function>

<#function getReferenceNote payment>
    <#assign paidTransactions = transHash[payment.internalid]>
    <#if paidTransactions?size == 1>
    	<#assign transaction = paidTransactions[0]>
        <#assign tranId = transaction.tranid>
        <#if tranId?has_content>
	         <#return tranId>
	    </#if>
    </#if>
	<#return "">
</#function>

<#-- Assign Initial Variables -->
<#assign totalAmount = 0>
<#assign totalPayments = 0>
<#assign recordCount = 0>
<#-- template building -->
#OUTPUT START#
H,P${"\n"}<#rt><#-- Header Record: Record Type=H ; File Type=P -->
<#list payments as payment>
    <#assign ebank = ebanks[payment_index]>
    <#assign entity = entities[payment_index]>
    <#assign amount = getAmount(payment)>
    <#assign totalAmount = totalAmount + amount>
    <#assign totalPayments = totalPayments + 1>
    <#assign recordCount = recordCount + 1>
<#-- Identify Country -->
<#assign bankCountry = "US">
<#-- <#if payment.class == "Taiwan">
	<#assign bankCountry = "TW">
<#elseif payment.class == "India">
	<#assign bankCountry = "IN">
</#if> -->
<#--P01-->P,<#rt>
<#-- United States Payments are all TT/ON -->
<#--P02-->TT,<#rt><#--TT=Telegraphic Transfer;RTGS=Wire Payments;CC=Corporate Cheque;Taiwan EFT=RTGS-->
<#--P03-->ON,<#rt><#--If RTGS or TT=ON, ACH=BA-->
<#--P04-->,<#rt><#--Not Used-->
<#--P05-->${setMaxLength(payment.tranid,16)},<#rt>
<#--P06-->,<#rt><#--Not Used-->
<#--P07-->US,<#rt><#--Debit Country Code (US)-->
<#--P08-->NY,<#rt><#--Debit City Code (NY)-->
<#--P09-->${setMaxLength(cbank.custpage_eft_custrecord_2663_acct_num,34)},<#rt><#--Bank Account Number-->
<#--P10-->${setMaxLength(pfa.custrecord_2663_process_date?string("dd/MM/yyyy"),10)},<#rt>
<#--P11-->"${setMaxLength(trimBankCountry(buildEntityName(entity, false)),35)}",<#rt><#--Payee Name-->
<#--P12-->,<#rt><#--Payee Address1-->
<#--P13-->,<#rt><#--Payee Address2-->
<#--P14-->,<#rt><#--Payee Address3-->
<#--P15-->,<#rt><#--Not Used-->
<#--P16-->${setMaxLength(ebank.custrecord_2663_entity_bank_no,17)},<#rt><#--Payee Bank Code/Branch Code (Taiwan); IFSC Code (India)-->
<#--P17-->,<#rt><#--Not Used-->
<#--P18-->,<#rt><#--Not Used--><#--Payee Branch Code-->
<#--P19-->,<#rt><#--Not Used-->
<#--P20-->${setMaxLength(ebank.custrecord_2663_entity_acct_no,34)},<#rt><#--Payee Account Number-->
<#--P21-->,<#rt><#--Not Used--><#--Payment Description on Check Payments (70)-->
<#--P22-->,<#rt><#--Not Used--><#--Payment Description on Check Payments (70)-->
<#--P23-->,<#rt><#--Not Used-->
<#--P24-->,<#rt><#--Not Used-->
<#--P25-->,<#rt><#--Not Used-->
<#--P26-->,<#rt><#--Not Used-->
<#--P27-->,<#rt><#--Not Used-->
<#--P28-->,<#rt><#--Not Used-->
<#--P29-->,<#rt><#--Not Used-->
<#--P30-->,<#rt><#--Not Used-->
<#--P31-->,<#rt><#--Not Used-->
<#--P32-->,<#rt><#--Not Used-->
<#--P33-->,<#rt><#--Not Used-->
<#--P34-->,<#rt><#--Not Used-->
<#--P35-->,<#rt><#--Not Used-->
<#--P36-->,<#rt><#--Not Used-->
<#--P37-->,<#rt><#--Not Used-->
<#--P38-->${getCurrencySymbol(payment.currency)},<#rt><#--Payment Currency-->
<#--P39-->${setMaxLength(formatAmount(amount,"dec"),14)},<#rt><#--Payment Amount-->
<#--P40-->C,<#rt><#--Local Charges To-->
<#--P41-->C,<#rt><#--Overseas Charges To-->
<#--P42-->,<#rt><#--Not Used--><#--Intermediary Bank Code (Swift Code)-->
<#--P43-->,<#rt><#--Not Used--><#--Clearing Code for TT-->
<#--P44-->,<#rt><#--Not Used--><#--Clearing Zone Code for LBC-->
<#--P45-->,<#rt><#--Not Used--><#--For IBC Only-->
<#--P46-->,<#rt><#--Delivery Method: M=Mail;C=Courier;P=Pickup-->
<#--P47-->,<#rt><#--Deliver To: C=GBT;P=Payee-->
<#--P48-->,<#rt><#--For LBC,CC. If Delivery method & Delivery to is 「P」 then this field needs to be indicated on where the cheques are to be picked up-->
<#--P49-->,<#rt>
<#--P50-->,<#rt><#--Not Used-->
<#--P51-->,<#rt>
<#--P52-->,<#rt>
<#--P53-->,<#rt>
<#--P54-->,<#rt>
<#--P55-->,<#rt>
<#--P56-->,<#rt>
<#--P57-->,<#rt>
<#--P58-->,<#rt>
<#--P59-->,<#rt>
<#--P60-->,<#rt><#--Debit Currency-->
<#--P61-->SCBLUS33XXX,<#rt><#--Debit Bank ID (R) (SCBLUS33XXX)-->
<#--P62-->,<#rt>
<#--P63-->${entity.email}<#rt><#--Email ID-->
${"\n"}<#--Line Break--><#rt>
</#list>
T,${setMaxLength(recordCount,5)},${setMaxLength(formatAmount(totalAmount,"dec"),14)}<#rt>
#OUTPUT END#
