#
# (C) Tenable Network Security, Inc.
#


include("compat.inc");

if (description)
{
 script_id(16095);
 script_cve_id("CVE-2005-0267", "CVE-2005-0268");
 script_bugtraq_id(12150);
 script_xref(name:"OSVDB", value:"15989");
 script_xref(name:"OSVDB", value:"12713");

 script_version("$Revision: 1.12 $");
 script_name(english:"FlatNuke index.php url_avatar Field Arbitrary PHP Code Execution");

 script_set_attribute(attribute:"synopsis", value:
"The remote web server contains a PHP application that is affected by
multiple vulnerabilities." );
 script_set_attribute(attribute:"description", value:
"The remote host is running FlatNuke, a content management system
written in PHP and using flat files rather than a database for its
storage. 

The remote version of this software has a form submission
vulnerability that may allow an attacker to execute arbitrary PHP
commands on the remote host." );
 script_set_attribute(attribute:"see_also", value:"http://marc.info/?l=bugtraq&m=110477752916772&w=2" );
 script_set_attribute(attribute:"solution", value:
"Upgrade to FlatNuke version 2.5.2 or later." );
 script_set_attribute(attribute:"cvss_vector", value: "CVSS2#AV:N/AC:L/Au:N/C:P/I:P/A:P" );

script_end_attributes();

 script_summary(english:"Determines if FlatNuke is installed");
 script_category(ACT_GATHER_INFO);
 script_family(english:"CGI abuses");
 script_copyright(english:"This script is Copyright (C) 2005-2009 Tenable Network Security, Inc.");
 script_dependencie("http_version.nasl");
 script_require_ports("Services/www", 80);
 script_exclude_keys("Settings/disable_cgi_scanning");
 exit(0);
}


include("global_settings.inc");
include("misc_func.inc");
include("http.inc");


port = get_http_port(default:80, embedded: 0);
if (!can_host_php(port:port)) exit(0);


# Search for FlatNuke.
if (thorough_tests) dirs = list_uniq(make_list("/flatnuke", cgi_dirs()));
else dirs = make_list(cgi_dirs());

foreach dir ( dirs )
{
res = http_get_cache(item:string(dir, "/index.php"), port:port);
if(isnull(res)) exit(0);

if ( 'Powered by <b><a href="http://flatnuke.sourceforge.net">' >< res )
{
 str = chomp(egrep(pattern:'Powered by <b><a href="http://flatnuke.sourceforge.net">', string:res));
 version = ereg_replace(pattern:".*flatnuke-([0-9.]*).*", string:str, replace:"\1");
 if ( dir == "" ) dir = "/";

 # nb: pages no longer seem to include a version number so don't rely on the
 #     KB entry at least until a more general detection plugin can be written.
 set_kb_item(name:"www/" + port + "/flatnuke", value: version + " under " + dir);

 if ( ereg(pattern:"^([0-1]\.|2\.([0-4]\.|5\.[0-1][^0-9]))", string:version) )
 	{
	security_hole( port );
	exit(0);
	}
 }
}
