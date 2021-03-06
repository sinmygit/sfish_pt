#
# (C) Tenable Network Security, Inc.
#

include("compat.inc");

if (description)
{
 script_id(42262);
 script_version("$Revision: 1.3 $");

 script_cve_id("CVE-2009-0840", "CVE-2009-2281");
 script_bugtraq_id(36802);
 script_xref(name:"OSVDB", value:"56330");
 script_xref(name:"OSVDB", value:"59284");
 script_xref(name:"Secunia", value:"34520");

 script_name(english:"MapServer < 5.4.2 / 5.2.3 / 4.10.5 Buffer Overflow");
 script_summary(english:"Performs a banner check");
 
 script_set_attribute(attribute:"synopsis", value:
"The remote web server contains a CGI script that is affected by 
a buffer overflow vulnerability." );
 script_set_attribute(attribute:"description", value:
"The remote host is running MapServer, an open source Internet map
server. The installed version reportedly contains an incomplete
fix for the vulnerability referenced by CVE-2009-0840. An attacker
may be able to exploit this issue to cause a denial of service
condition or execute arbitrary code on the remote system.");

 script_set_attribute(attribute:"see_also", value:"http://trac.osgeo.org/mapserver/ticket/2943" );
 script_set_attribute(attribute:"see_also", value:"http://trac.osgeo.org/mapserver/browser/tags/rel-4-10-5/mapserver/HISTORY.TXT" );
 script_set_attribute(attribute:"see_also", value:"http://trac.osgeo.org/mapserver/browser/tags/rel-5-2-3/mapserver/HISTORY.TXT" );
 script_set_attribute(attribute:"see_also", value:"http://trac.osgeo.org/mapserver/browser/tags/rel-5-4-2/mapserver/HISTORY.TXT" );
 script_set_attribute(attribute:"solution", value:
"Upgrade to MapServer 5.4.2 / 5.2.3 / 4.10.5." );
 script_set_attribute(attribute:"cvss_vector", value: "CVSS2#AV:N/AC:L/Au:N/C:C/I:C/A:C" );
  
  script_set_attribute(attribute:"vuln_publication_date", value:"2009/03/17");
  script_set_attribute(attribute:"patch_publication_date", value:"2009/07/23");
  script_set_attribute(attribute:"plugin_publication_date",value:"2009/10/27");

 script_end_attributes();
 
 script_category(ACT_GATHER_INFO);
 script_family(english:"CGI abuses");

 script_copyright(english:"This script is Copyright (C) 2009 Tenable Network Security, Inc.");

 script_dependencies("http_version.nasl");
 script_require_ports("Services/www", 80);

  exit(0);
}

include("global_settings.inc");
include("http.inc");
include("misc_func.inc");

if(report_paranoia < 2) exit(1, "This plugin only runs if 'Report paranoia' is set to 'Paranoid'.");

port = get_http_port(default:80);

url = "/cgi-bin/mapserv.exe?map=nessus.map";

res = http_send_recv3(method:"GET", item:url, port:port);
if (isnull(res))  exit(1, "The web server on port "+port+" failed to respond.");

if("MapServer Message" >!< res[2])
{
 url  = "/cgi-bin/mapserv?map=nessus.map";
 res = http_send_recv3(method:"GET", item:url, port:port);
 if (isnull(res))  exit(1, "The web server on port "+port+" failed to respond.");
}

# Do a banner check.
if (res[2] &&
  'msLoadMap(): Unable to access file. (nessus.map)' >< res[2] &&
  egrep(pattern:"<!-- MapServer version [0-9]+\.[0-9]+\.[0-9]+ ", string:res[2])
)
{
 version = ereg_replace(pattern:".*<!-- MapServer version ([0-9]+\.[0-9]+\.[0-9]+) .*", string:res[2], replace:"\1");
 
 vers = split(version, sep:".", keep:FALSE);
 for (i=0; i<max_index(vers); i++)
    vers[i] = int(vers[i]);

 if ( ( vers[0]  < 4 ) ||
      ( vers[0] == 4 && vers[1]  < 10 ) ||
      ( vers[0] == 4 && vers[1] == 10 &&  vers[2] < 5 ) ||
      ( vers[0] == 5 && vers[1]  < 2 ) ||
      ( vers[0] == 5 && vers[1] == 2 &&   vers[2] < 3 ) ||
      ( vers[0] == 5 && vers[1] == 3 ) ||
      ( vers[0] == 5 && vers[1] == 4 &&   vers[2] < 2 ))
  {
    if(report_verbosity > 0)
    {
      report = string("\n",
                 "MapServer version ", version, " is running on the remote host.\n");
      security_hole(port:port,extra:report);
    }         
    else
     security_hole(port);
  }
  exit(0, "Mapserver version "+version+" is installed and not vulnerable.");
}
