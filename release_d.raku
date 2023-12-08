use JSON::Fast;

sub MAIN() {
    given from-json(slurp('META6.json')) -> (:$version!, *%) {
        my Str:D $datetime = DateTime.now.Str;
        my Str:D $filename = "archive/{$datetime}-Gzz-Text-Utils-{$version}.tar.gz";
        shell("git archive --format=tar.gz --output=$filename HEAD");
        shell("fez upload --file=$filename");
        tag("release-$version");
    }
}

sub tag($tag) {
    shell "git tag -a -m '$tag' $tag && git push --tags origin"
}
