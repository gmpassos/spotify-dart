// Copyright (c) 2017, rinukkusu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

/// Endpoint for artists `v1/artists`
class Artists extends EndpointPaging {
  @override
  String get _path => 'v1/artists';

  Artists(SpotifyApiBase api) : super(api);

  /// Retrieves an artist with its [artistId]
  Future<Artist> get(String artistId) async {
    var jsonString = await _api._get('$_path/$artistId');
    var map = json.decode(jsonString);

    return Artist.fromJson(map);
  }

  /// Returns the top tracks of an artist with its [artistId] inside a [country]
  @Deprecated('Use [topTracks] instead')
  Future<Iterable<Track>> getTopTracks(String artistId, String country) {
    var contains = Market.values.asNameMap().containsKey(country);
    assert(contains == true,
        'The country code $country does not match with any Market enum value');
    return topTracks(artistId, Market.values.asNameMap()[country]!);
  }

  /// Returns the top tracks of an artist with its [artistId] inside a [country]
  Future<Iterable<Track>> topTracks(String artistId, Market country) async {
    var query = _buildQuery({
      'country': country.name,
    });
    var jsonString = await _api._get('$_path/$artistId/top-tracks?$query');
    var map = json.decode(jsonString);

    var topTracks = map['tracks'] as Iterable<dynamic>;
    return topTracks.map((m) => Track.fromJson(m));
  }

  /// Returns related artists based on the artist with its [artistId]
  @Deprecated('Use relatedArtists instead')
  Future<Iterable<Artist>> getRelatedArtists(String artistId) async =>
      relatedArtists(artistId);

  /// Retrieves multiple artists with [artistIds]
  Future<Iterable<Artist>> list(List<String> artistIds) async => _listWithIds(
      path: _path,
      ids: artistIds,
      jsonKey: 'artists',
      fromJson: Artist.fromJson);

  /// Returns related artists based on the artist with its [artistId]
  Future<Iterable<Artist>> relatedArtists(String artistId) async => _list(
      path: '$_path/$artistId/related-artists',
      jsonKey: 'artists',
      fromJson: Artist.fromJson);

  /// [includeGroups] - A comma-separated list of keywords that will be used to
  /// filter the response. If not supplied, all album types will be returned.
  /// Valid values are: 'album', 'single', 'appears_on', 'compilation'
  ///
  /// [country] - An ISO 3166-1 alpha-2 country code or the string from_token.
  /// Supply this parameter to limit the response to one particular geographical
  /// market. For example, for albums available in Sweden: country=SE.
  /// If not given, results will be returned for all countries and you are
  /// likely to get duplicate results per album, one for each country in which
  /// the album is available!
  Pages<Album> albums(
    String artistId, {
    Market? country,
    List<String>? includeGroups,
  }) {
    final _includeGroups = includeGroups?.join(',');
    final query = _buildQuery({
      'include_groups': _includeGroups,
      'country': country?.name,
    });
    return _getPages(
        '$_path/$artistId/albums?$query', (json) => Album.fromJson(json));
  }
}
