// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleModelAdapter extends TypeAdapter<ArticleModel> {
  @override
  final int typeId = 21;

  @override
  ArticleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleModel(
      id: fields[0] as String,
      category: fields[1] as String,
      themeName: fields[2] as String,
      title: fields[3] as String,
      excerpt: fields[4] as String,
      body: fields[5] as String,
      imageUrl: fields[6] as String?,
      readTime: fields[7] as String,
      source: fields[8] as String,
      likes: fields[9] as int,
      comments: fields[10] as int,
      publishedAt: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.themeName)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.excerpt)
      ..writeByte(5)
      ..write(obj.body)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.readTime)
      ..writeByte(8)
      ..write(obj.source)
      ..writeByte(9)
      ..write(obj.likes)
      ..writeByte(10)
      ..write(obj.comments)
      ..writeByte(11)
      ..write(obj.publishedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
