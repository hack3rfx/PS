$email = Read-Host "Enter your email address";

$domainExceptions = "aol.com", "att.net", "comcast.net", "facebook.com", "gmail.com", "gmx.com", "googlemail.com", "google.com", "hotmail.com", "hotmail.co.uk", "mac.com", "me.com", "mail.com", "msn.com", "live.com", "sbcglobal.net", "verizon.net", "yahoo.com", "yahoo.co.uk", "email.com", "fastmail.fm", "games.com", "gmx.net", "hush.com", "hushmail.com", "icloud.com", "iname.com", "inbox.com", "lavabit.com", "love.com", "outlook.com", "pobox.com", "protonmail.ch", "protonmail.com", "tutanota.de", "tutanota.com", "tutamail.com", "tuta.io", "keemail.me", "rocketmail.com", "safe-mail.net", "wow.com", "ygm.com", "ymail.com", "zoho.com", "yandex.com", "bellsouth.net", "charter.net", "cox.net", "earthlink.net", "juno.com", "btinternet.com", "virginmedia.com", "blueyonder.co.uk", "freeserve.co.uk", "live.co.uk", "ntlworld.com", "o2.co.uk", "orange.net", "sky.com", "talktalk.co.uk", "tiscali.co.uk", "virgin.net", "wanadoo.co.uk", "bt.com", "sina.com", "sina.cn", "qq.com", "naver.com", "hanmail.net", "daum.net", "nate.com", "yahoo.co.jp", "yahoo.co.kr", "yahoo.co.id", "yahoo.co.in", "yahoo.com.sg", "yahoo.com.ph", "163.com", "yeah.net", "126.com", "21cn.com", "aliyun.com", "foxmail.com", "hotmail.fr", "live.fr", "laposte.net", "yahoo.fr", "wanadoo.fr", "orange.fr", "gmx.fr", "sfr.fr", "neuf.fr", "free.fr", "gmx.de", "hotmail.de", "live.de", "online.de", "t-online.de", "web.de", "yahoo.de", "libero.it", "virgilio.it", "hotmail.it", "aol.it", "tiscali.it", "alice.it", "live.it", "yahoo.it", "email.it", "tin.it", "poste.it", "teletu.it", "mail.ru", "rambler.ru", "yandex.ru", "ya.ru", "list.ru", "hotmail.be", "live.be", "skynet.be", "voo.be", "tvcablenet.be", "telenet.be", "hotmail.com.ar", "live.com.ar", "yahoo.com.ar", "fibertel.com.ar", "speedy.com.ar", "arnet.com.ar", "yahoo.com.mx", "live.com.mx", "hotmail.es", "hotmail.com.mx", "prodigy.net.mx", "yahoo.ca", "hotmail.ca", "bell.net", "shaw.ca", "sympatico.ca", "rogers.com", "yahoo.com.br", "hotmail.com.br", "outlook.com.br", "uol.com.br", "bol.com.br", "terra.com.br", "ig.com.br", "itelefonica.com.br", "r7.com", "zipmail.com.br", "globo.com", "globomail.com", "oi.com.br";

$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Authentication basic -AllowRedirection -Credential $email;
Import-PSSession $s;


$addresses = (Get-MailboxJunkEmailConfiguration -Identity $email).BlockedSendersAndDomains;
$addressesCopy = $addresses.clone();

$changesMade = $false;

$addresses | ForEach-Object {
	$new = $_;
	
	If ($new -Match '@') {
		$length = $new.length;
		$index = $new.LastIndexOf('@');
		$new = $new.Substring($index+1,$length-$index-1);
	}
	
	If (($new.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count -gt 1) {
		If ($new -NotLike '*.co.*') {
			$new = $new.Substring($new.Substring(0, $new.LastIndexOf(".")).LastIndexOf(".") + 1);
		}
	}
	
	If ($new -ne $_) {
		if (!$domainExceptions.Contains($new)){
			Write-Host "$_ -> $new";
			$addressesCopy.Remove($_);
			if (!$addressesCopy.Contains($new)) {
				$addressesCopy.Add($new);
			}
			$changesMade = $true;
		}
	}
}
	
"----------------"

if ($changesMade) {
	"Saving changes"
	Set-MailboxJunkEmailConfiguration -Identity $email -BlockedSendersAndDomains $addressesCopy
} else {
	"No changes made"
}


Remove-PSSession -Session $s;

Read-Host "Press [ENTER] to exit";
