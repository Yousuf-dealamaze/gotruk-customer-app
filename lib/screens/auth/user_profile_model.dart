class ProfileResponse {
  final bool success;
  final int code;
  final String message;
  final ProfileData data;

  ProfileResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: ProfileData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class ProfileData {
  final String id;
  final String userType;
  final String displayId;
  final String? departmentId;
  final String? displayName;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phoneNumber;
  final bool phoneVerification;
  final bool emailVerification;
  final String gender;
  final String status;
  final String? parentTransporterId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? userProfile;
  final List<FileModel> fileModel;

  ProfileData({
    required this.id,
    required this.userType,
    required this.displayId,
    this.departmentId,
    this.displayName,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    required this.phoneVerification,
    required this.emailVerification,
    required this.gender,
    required this.status,
    this.parentTransporterId,
    required this.createdAt,
    required this.updatedAt,
    this.userProfile,
    required this.fileModel,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      userType: json['userType'] ?? '',
      displayId: json['displayId'] ?? '',
      departmentId: json['departmentId'],
      displayName: json['displayName'],
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      countryCode: json['countryCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      phoneVerification: json['phoneVerification'] ?? false,
      emailVerification: json['emailVerification'] ?? false,
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
      parentTransporterId: json['parentTransporterId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userProfile: json['userProfile'] != null
          ? UserProfile.fromJson(json['userProfile'])
          : null,
      fileModel:
          (json['fileModel'] as List<dynamic>?)
              ?.map((e) => FileModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userType": userType,
    "displayId": displayId,
    "departmentId": departmentId,
    "displayName": displayName,
    "username": username,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "countryCode": countryCode,
    "phoneNumber": phoneNumber,
    "phoneVerification": phoneVerification,
    "emailVerification": emailVerification,
    "gender": gender,
    "status": status,
    "parentTransporterId": parentTransporterId,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "userProfile": userProfile?.toJson(),
    "fileModel": fileModel.map((e) => e.toJson()).toList(),
  };
}

class UserProfile {
  final String id;
  final String userId;
  final String? idProof;
  final String? idProofType;
  final String? idProofDoc;
  final String? addressProof;
  final String? addressProofType;
  final String? addressProofDoc;
  final String? registrationProof;
  final String? registrationProofType;
  final String? registrationProofDoc;
  final String? displayPic;
  final String? logoPic;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.idProof,
    this.idProofType,
    this.idProofDoc,
    this.addressProof,
    this.addressProofType,
    this.addressProofDoc,
    this.registrationProof,
    this.registrationProofType,
    this.registrationProofDoc,
    this.displayPic,
    this.logoPic,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      idProof: json['idProof'],
      idProofType: json['idProofType'],
      idProofDoc: json['idProofDoc'],
      addressProof: json['addressProof'],
      addressProofType: json['addressProofType'],
      addressProofDoc: json['addressProofDoc'],
      registrationProof: json['registrationProof'],
      registrationProofType: json['registrationProofType'],
      registrationProofDoc: json['registrationProofDoc'],
      displayPic: json['displayPic'],
      logoPic: json['logoPic'],
      description: json['description'],
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "idProof": idProof,
    "idProofType": idProofType,
    "idProofDoc": idProofDoc,
    "addressProof": addressProof,
    "addressProofType": addressProofType,
    "addressProofDoc": addressProofDoc,
    "registrationProof": registrationProof,
    "registrationProofType": registrationProofType,
    "registrationProofDoc": registrationProofDoc,
    "displayPic": displayPic,
    "logoPic": logoPic,
    "description": description,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class FileModel {
  final String id;
  final String userId;
  final String fileName;
  final String dirName;
  final String path;
  final int filesize;
  final String minType;
  final String bucket;
  final String url;
  final String? documentType;
  final String? documentId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FileModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.dirName,
    required this.path,
    required this.filesize,
    required this.minType,
    required this.bucket,
    required this.url,
    this.documentType,
    this.documentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? '',
      dirName: json['dirName'] ?? '',
      path: json['path'] ?? '',
      filesize: json['filesize'] ?? 0,
      minType: json['minType'] ?? '',
      bucket: json['bucket'] ?? '',
      url: json['url'] ?? '',
      documentType: json['documentType'],
      documentId: json['documentId'],
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "fileName": fileName,
    "dirName": dirName,
    "path": path,
    "filesize": filesize,
    "minType": minType,
    "bucket": bucket,
    "url": url,
    "documentType": documentType,
    "documentId": documentId,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
