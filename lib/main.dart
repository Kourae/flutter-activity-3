import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const PokemonDetailScreen(),
    );
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final String type;
  final int baseExperience;
  final int height;
  final int weight;
  final List<String> abilities;
  final List<String> moves;
  final String imageUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.moves,
    required this.imageUrl,
  });

  factory PokemonDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    final abilities =
        (json['abilities'] as List?)
                ?.map(
                  (a) =>
                      a['ability']['name']
                          .toString(),
                )
                .toList() ??
            [];

    final moves =
        (json['moves'] as List?)
                ?.map(
                  (m) =>
                      m['move']['name']
                          .toString(),
                )
                .toList() ??
            [];

    final type =
        (json['types'] as List?)
                ?.map(
                  (t) =>
                      t['type']['name']
                          .toString(),
                )
                .join(', ') ??
            '';

    final imageUrl =
        json['sprites']?['other']
                ?['official-artwork']
            ?['front_default'] ??
            '';

    return PokemonDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: type,
      baseExperience:
          json['base_experience'] ?? 0,
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      abilities: abilities,
      moves: moves,
      imageUrl: imageUrl,
    );
  }
}

class PokemonDetailScreen
    extends StatefulWidget {
  const PokemonDetailScreen({
    super.key,
  });

  @override
  State<PokemonDetailScreen>
      createState() =>
          _PokemonDetailScreenState();
}

class _PokemonDetailScreenState
    extends State<PokemonDetailScreen> {
  Future<PokemonDetail>? pokemonFuture;

  final TextEditingController
      searchController =
      TextEditingController();

  Future<PokemonDetail> loadPokemon(
    String name,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${name.toLowerCase().trim()}',
      ),
    );

    if (response.statusCode == 200) {
      final json =
          jsonDecode(response.body);

      return PokemonDetail.fromJson(
        json,
      );
    }

    throw Exception(
      'Pokémon not found',
    );
  }

  void searchPokemon() {
    final pokemonName =
        searchController.text
            .trim()
            .toLowerCase();

    if (pokemonName.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      pokemonFuture =
          loadPokemon(pokemonName);
    });
  }

  Widget infoTile(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFFD1C4E9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),

              const Text(
                "Pokedex",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Padding(
                padding:
                    const EdgeInsets
                        .all(16),
                child: Material(
                  elevation: 8,
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                  child: TextField(
                    controller:
                        searchController,
                    onSubmitted:
                        (_) =>
                            searchPokemon(),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search Pokemon...',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                          IconButton(
                        icon:
                            const Icon(
                          Icons
                              .catching_pokemon,
                        ),
                        onPressed:
                            searchPokemon,
                      ),
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                        borderSide:
                            BorderSide
                                .none,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child:
                    pokemonFuture ==
                            null
                        ? const Center(
                            child:
                                Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons
                                      .catching_pokemon,
                                  size:
                                      120,
                                  color:
                                      Colors
                                          .white,
                                ),
                                SizedBox(
                                  height:
                                      20,
                                ),
                                Text(
                                  'Welcome Trainer!',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        28,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      10,
                                ),
                                Text(
                                  'Search for a Pokemon.',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FutureBuilder<
                            PokemonDetail>(
                            future:
                                pokemonFuture,
                            builder:
                                (
                                  context,
                                  snapshot,
                                ) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.white,
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Center(
                                      child:
                                          Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size:
                                                80,
                                            color:
                                                Colors.white,
                                          ),
                                          const SizedBox(
                                            height:
                                                16,
                                          ),
                                          Text(
                                            snapshot.error.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final pokemon =
                                      snapshot.data!;

                                  return SingleChildScrollView(
                                    child:
                                        Card(
                                      margin:
                                          const EdgeInsets.all(
                                        16,
                                      ),
                                      elevation:
                                          10,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          24,
                                        ),
                                      ),
                                      child:
                                          Padding(
                                        padding:
                                            const EdgeInsets.all(
                                          20,
                                        ),
                                        child:
                                            Column(
                                          children: [
                                            Image.network(
                                              pokemon.imageUrl,
                                              height:
                                                  220,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                return const Icon(
                                                  Icons.catching_pokemon,
                                                  size:
                                                      140,
                                                );
                                              },
                                            ),

                                            const SizedBox(
                                              height:
                                                  12,
                                            ),

                                            Text(
                                              pokemon.name.toUpperCase(),
                                              textAlign:
                                                  TextAlign.center,
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    30,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color:
                                                    Colors.deepPurple,
                                              ),
                                            ),

                                            const Divider(
                                              height:
                                                  32,
                                            ),

                                            infoTile(
                                              'ID',
                                              '#${pokemon.id}',
                                            ),
                                            infoTile(
                                              'Type',
                                              pokemon.type,
                                            ),
                                            infoTile(
                                              'Base XP',
                                              pokemon.baseExperience.toString(),
                                            ),
                                            infoTile(
                                              'Height',
                                              pokemon.height.toString(),
                                            ),
                                            infoTile(
                                              'Weight',
                                              pokemon.weight.toString(),
                                            ),

                                            const SizedBox(
                                              height:
                                                  20,
                                            ),

                                            const Align(
                                              alignment:
                                                  Alignment.centerLeft,
                                              child:
                                                  Text(
                                                'Abilities',
                                                style:
                                                    TextStyle(
                                                  fontSize:
                                                      20,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  10,
                                            ),

                                            Wrap(
                                              spacing:
                                                  8,
                                              children:
                                                  pokemon.abilities
                                                      .map(
                                                        (
                                                          ability,
                                                        ) =>
                                                            Chip(
                                                          label:
                                                              Text(
                                                            ability,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),

                                            const SizedBox(
                                              height:
                                                  20,
                                            ),

                                            const Align(
                                              alignment:
                                                  Alignment.centerLeft,
                                              child:
                                                  Text(
                                                'Moves',
                                                style:
                                                    TextStyle(
                                                  fontSize:
                                                      20,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  10,
                                            ),

                                            Wrap(
                                              spacing:
                                                  8,
                                              runSpacing:
                                                  8,
                                              children:
                                                  pokemon.moves
                                                      .take(
                                                        20,
                                                      )
                                                      .map(
                                                        (
                                                          move,
                                                        ) =>
                                                            Chip(
                                                          label:
                                                              Text(
                                                            move,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}