#!/usr/bin/perl

use warnings;
use strict;

use HTTP::Daemon;
use HTTP::Status;

die "Usage: $0 port file type\n" unless @ARGV == 3;
my ($PORT, $FILE, $TYPE) = @ARGV;

my $d = HTTP::Daemon->new(LocalPort => $PORT, ReuseAddr => 1)
    or die "Couldn't create socket: $!\n";
print "Lausche auf ", $d->url, "...\n";

while(my $conn = $d->accept()) {
    my $pid = fork();
    defined $pid or die "Couldn't fork: $!\n";
    next if $pid;

    while(my $req = $conn->get_request()) {
        printf "Anfrage von %s:%s: %s %s\n", $conn->peerhost, $conn->peerport, $req->method, $req->uri->path;
        $conn->send_basic_header();
        $conn->send_header("Content-Type", $TYPE);
        $conn->send_header("Content-Length", (stat $FILE)[7]);
        $conn->send_crlf();
        $conn->send_file($FILE);
    }
    $conn->close();
    exit;
}
