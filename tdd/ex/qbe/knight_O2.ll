; ModuleID = 'knight.c'
source_filename = "knight.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

@N = local_unnamed_addr global i32 0, align 4
@t = common local_unnamed_addr global i64* null, align 8
@.str = private unnamed_addr constant [7 x i8] c"t: %s\0A\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c" %02d\00", align 1
@b = common local_unnamed_addr global i32** null, align 8

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @board() local_unnamed_addr #0 {
  %1 = load i64*, i64** @t, align 8, !tbaa !10
  %2 = tail call i64 @time(i64* noundef %1) #9
  %3 = load i64*, i64** @t, align 8, !tbaa !10
  %4 = tail call i8* @ctime(i64* noundef %3) #9
  %5 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i64 0, i64 0), i8* noundef %4)
  br label %6

6:                                                ; preds = %0, %6
  %7 = phi i64 [ 0, %0 ], [ %56, %6 ]
  %8 = load i32**, i32*** @b, align 8, !tbaa !10
  %9 = load i32*, i32** %8, align 8, !tbaa !10
  %10 = getelementptr inbounds i32, i32* %9, i64 %7
  %11 = load i32, i32* %10, align 4, !tbaa !14
  %12 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %11)
  %13 = load i32**, i32*** @b, align 8, !tbaa !10
  %14 = getelementptr inbounds i32*, i32** %13, i64 1
  %15 = load i32*, i32** %14, align 8, !tbaa !10
  %16 = getelementptr inbounds i32, i32* %15, i64 %7
  %17 = load i32, i32* %16, align 4, !tbaa !14
  %18 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %17)
  %19 = load i32**, i32*** @b, align 8, !tbaa !10
  %20 = getelementptr inbounds i32*, i32** %19, i64 2
  %21 = load i32*, i32** %20, align 8, !tbaa !10
  %22 = getelementptr inbounds i32, i32* %21, i64 %7
  %23 = load i32, i32* %22, align 4, !tbaa !14
  %24 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %23)
  %25 = load i32**, i32*** @b, align 8, !tbaa !10
  %26 = getelementptr inbounds i32*, i32** %25, i64 3
  %27 = load i32*, i32** %26, align 8, !tbaa !10
  %28 = getelementptr inbounds i32, i32* %27, i64 %7
  %29 = load i32, i32* %28, align 4, !tbaa !14
  %30 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %29)
  %31 = load i32**, i32*** @b, align 8, !tbaa !10
  %32 = getelementptr inbounds i32*, i32** %31, i64 4
  %33 = load i32*, i32** %32, align 8, !tbaa !10
  %34 = getelementptr inbounds i32, i32* %33, i64 %7
  %35 = load i32, i32* %34, align 4, !tbaa !14
  %36 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %35)
  %37 = load i32**, i32*** @b, align 8, !tbaa !10
  %38 = getelementptr inbounds i32*, i32** %37, i64 5
  %39 = load i32*, i32** %38, align 8, !tbaa !10
  %40 = getelementptr inbounds i32, i32* %39, i64 %7
  %41 = load i32, i32* %40, align 4, !tbaa !14
  %42 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %41)
  %43 = load i32**, i32*** @b, align 8, !tbaa !10
  %44 = getelementptr inbounds i32*, i32** %43, i64 6
  %45 = load i32*, i32** %44, align 8, !tbaa !10
  %46 = getelementptr inbounds i32, i32* %45, i64 %7
  %47 = load i32, i32* %46, align 4, !tbaa !14
  %48 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %47)
  %49 = load i32**, i32*** @b, align 8, !tbaa !10
  %50 = getelementptr inbounds i32*, i32** %49, i64 7
  %51 = load i32*, i32** %50, align 8, !tbaa !10
  %52 = getelementptr inbounds i32, i32* %51, i64 %7
  %53 = load i32, i32* %52, align 4, !tbaa !14
  %54 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %53)
  %55 = tail call i32 @putchar(i32 10)
  %56 = add nuw nsw i64 %7, 1
  %57 = icmp eq i64 %56, 8
  br i1 %57, label %58, label %6, !llvm.loop !16

58:                                               ; preds = %6
  %59 = tail call i32 @putchar(i32 10)
  ret i32 0
}

declare i64 @time(i64* noundef) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #2

declare i8* @ctime(i64* noundef) local_unnamed_addr #1



;; CHK



; Function Attrs: mustprogress nofree norecurse nosync nounwind readonly ssp willreturn uwtable(sync)
define i32 @chk(i32 noundef %0, i32 noundef %1) local_unnamed_addr #3 {
  %3 = or i32 %1, %0
  %4 = icmp ult i32 %3, 8
  br i1 %4, label %5, label %15

5:                                                ; preds = %2
  %6 = load i32**, i32*** @b, align 8, !tbaa !10
  %7 = zext i32 %0 to i64
  %8 = getelementptr inbounds i32*, i32** %6, i64 %7
  %9 = load i32*, i32** %8, align 8, !tbaa !10
  %10 = zext i32 %1 to i64
  %11 = getelementptr inbounds i32, i32* %9, i64 %10
  %12 = load i32, i32* %11, align 4, !tbaa !14
  %13 = icmp eq i32 %12, 0
  %14 = zext i1 %13 to i32
  br label %15

15:                                               ; preds = %2, %5
  %16 = phi i32 [ %14, %5 ], [ 0, %2 ]
  ret i32 %16
}



;; GO



; Function Attrs: nounwind ssp uwtable(sync)
define i32 @go(i32 noundef %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
  %4 = load i32**, i32*** @b, align 8, !tbaa !10
  %5 = sext i32 %1 to i64
  %6 = getelementptr inbounds i32*, i32** %4, i64 %5
  %7 = load i32*, i32** %6, align 8, !tbaa !10
  %8 = sext i32 %2 to i64
  %9 = getelementptr inbounds i32, i32* %7, i64 %8
  store i32 %0, i32* %9, align 4, !tbaa !14
  %10 = icmp eq i32 %0, 64
  br i1 %10, label %22, label %11

11:                                               ; preds = %3
  %12 = add nsw i32 %0, 1
  %13 = zext i32 %2 to i64
  %14 = add nsw i32 %2, -1
  %15 = zext i32 %14 to i64
  %16 = add nsw i32 %2, 1
  %17 = zext i32 %16 to i64
  %18 = add nsw i32 %2, -2
  %19 = zext i32 %18 to i64
  %20 = add nsw i32 %2, 2
  %21 = zext i32 %20 to i64
  br label %40

22:                                               ; preds = %3
  %23 = icmp ne i32 %1, 2
  %24 = icmp ne i32 %2, 0
  %25 = and i1 %23, %24
  br i1 %25, label %26, label %105

26:                                               ; preds = %22
  %27 = add nsw i32 %1, -2
  %28 = icmp slt i32 %1, 2
  %29 = sub i32 2, %1
  %30 = select i1 %28, i32 %29, i32 %27
  %31 = tail call i32 @llvm.abs.i32(i32 %2, i1 true)
  %32 = add nsw i32 %30, %31
  %33 = icmp eq i32 %32, 3
  br i1 %33, label %34, label %105

34:                                               ; preds = %26
  %35 = tail call i32 @board()
  %36 = load i32, i32* @N, align 4, !tbaa !14
  %37 = add nsw i32 %36, 1
  store i32 %37, i32* @N, align 4, !tbaa !14
  %38 = icmp eq i32 %37, 10
  br i1 %38, label %39, label %105

39:                                               ; preds = %34
  tail call void @exit(i32 noundef 0) #10
  unreachable

40:                                               ; preds = %11, %102
  %41 = phi i32 [ -2, %11 ], [ %103, %102 ]
  %42 = tail call i32 @llvm.abs.i32(i32 %41, i1 true)
  %43 = add nsw i32 %41, %1
  %44 = zext i32 %43 to i64
  switch i32 %42, label %102 [
    i32 1, label %45
    i32 2, label %57
    i32 3, label %69
  ]

45:                                               ; preds = %40
  %46 = or i32 %18, %43
  %47 = icmp ult i32 %46, 8
  br i1 %47, label %48, label %89

48:                                               ; preds = %45
  %49 = load i32**, i32*** @b, align 8, !tbaa !10
  %50 = getelementptr inbounds i32*, i32** %49, i64 %44
  %51 = load i32*, i32** %50, align 8, !tbaa !10
  %52 = getelementptr inbounds i32, i32* %51, i64 %19
  %53 = load i32, i32* %52, align 4, !tbaa !14
  %54 = icmp eq i32 %53, 0
  br i1 %54, label %55, label %89

55:                                               ; preds = %48
  %56 = tail call i32 @go(i32 noundef %12, i32 noundef %43, i32 noundef %18)
  br label %89

57:                                               ; preds = %40
  %58 = or i32 %14, %43
  %59 = icmp ult i32 %58, 8
  br i1 %59, label %60, label %79

60:                                               ; preds = %57
  %61 = load i32**, i32*** @b, align 8, !tbaa !10
  %62 = getelementptr inbounds i32*, i32** %61, i64 %44
  %63 = load i32*, i32** %62, align 8, !tbaa !10
  %64 = getelementptr inbounds i32, i32* %63, i64 %15
  %65 = load i32, i32* %64, align 4, !tbaa !14
  %66 = icmp eq i32 %65, 0
  br i1 %66, label %67, label %79

67:                                               ; preds = %60
  %68 = tail call i32 @go(i32 noundef %12, i32 noundef %43, i32 noundef %14)
  br label %79

69:                                               ; preds = %40
  %70 = or i32 %43, %2
  %71 = icmp ult i32 %70, 8
  br i1 %71, label %72, label %102

72:                                               ; preds = %69
  %73 = load i32**, i32*** @b, align 8, !tbaa !10
  %74 = getelementptr inbounds i32*, i32** %73, i64 %44
  %75 = load i32*, i32** %74, align 8, !tbaa !10
  %76 = getelementptr inbounds i32, i32* %75, i64 %13
  %77 = load i32, i32* %76, align 4, !tbaa !14
  %78 = icmp eq i32 %77, 0
  br i1 %78, label %99, label %102

79:                                               ; preds = %57, %60, %67
  %80 = or i32 %16, %43
  %81 = icmp ult i32 %80, 8
  br i1 %81, label %82, label %102

82:                                               ; preds = %79
  %83 = load i32**, i32*** @b, align 8, !tbaa !10
  %84 = getelementptr inbounds i32*, i32** %83, i64 %44
  %85 = load i32*, i32** %84, align 8, !tbaa !10
  %86 = getelementptr inbounds i32, i32* %85, i64 %17
  %87 = load i32, i32* %86, align 4, !tbaa !14
  %88 = icmp eq i32 %87, 0
  br i1 %88, label %99, label %102

89:                                               ; preds = %45, %48, %55
  %90 = or i32 %20, %43
  %91 = icmp ult i32 %90, 8
  br i1 %91, label %92, label %102

92:                                               ; preds = %89
  %93 = load i32**, i32*** @b, align 8, !tbaa !10
  %94 = getelementptr inbounds i32*, i32** %93, i64 %44
  %95 = load i32*, i32** %94, align 8, !tbaa !10
  %96 = getelementptr inbounds i32, i32* %95, i64 %21
  %97 = load i32, i32* %96, align 4, !tbaa !14
  %98 = icmp eq i32 %97, 0
  br i1 %98, label %99, label %102

99:                                               ; preds = %92, %82, %72
  %100 = phi i32 [ %2, %72 ], [ %16, %82 ], [ %20, %92 ]
  %101 = tail call i32 @go(i32 noundef %12, i32 noundef %43, i32 noundef %100)
  br label %102

102:                                              ; preds = %99, %40, %69, %72, %79, %82, %92, %89
  %103 = add nsw i32 %41, 1
  %104 = icmp eq i32 %103, 3
  br i1 %104, label %105, label %40, !llvm.loop !18

105:                                              ; preds = %102, %22, %26, %34
  %106 = load i32**, i32*** @b, align 8, !tbaa !10
  %107 = getelementptr inbounds i32*, i32** %106, i64 %5
  %108 = load i32*, i32** %107, align 8, !tbaa !10
  %109 = getelementptr inbounds i32, i32* %108, i64 %8
  store i32 0, i32* %109, align 4, !tbaa !14
  ret i32 0
}

; Function Attrs: noreturn
declare void @exit(i32 noundef) local_unnamed_addr #4



;; MAIN



; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() local_unnamed_addr #0 {
  %1 = tail call dereferenceable_or_null(8) i8* @malloc(i64 noundef 8) #11
  %2 = bitcast i8* %1 to i64*
  store i8* %1, i8** bitcast (i64** @t to i8**), align 8, !tbaa !10
  %3 = tail call i64 @time(i64* noundef %2) #9
  %4 = load i64*, i64** @t, align 8, !tbaa !10
  %5 = tail call i8* @ctime(i64* noundef %4) #9
  %6 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i64 0, i64 0), i8* noundef %5)
  %7 = tail call dereferenceable_or_null(64) i8* @calloc(i64 noundef 8, i64 noundef 8) #12
  store i8* %7, i8** bitcast (i32*** @b to i8**), align 8, !tbaa !10
  %8 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %9 = bitcast i8* %7 to i32**
  %10 = bitcast i8* %7 to i8**
  store i8* %8, i8** %10, align 8, !tbaa !10
  %11 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %12 = getelementptr inbounds i32*, i32** %9, i64 1
  %13 = bitcast i32** %12 to i8**
  store i8* %11, i8** %13, align 8, !tbaa !10
  %14 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %15 = getelementptr inbounds i32*, i32** %9, i64 2
  %16 = bitcast i32** %15 to i8**
  store i8* %14, i8** %16, align 8, !tbaa !10
  %17 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %18 = getelementptr inbounds i32*, i32** %9, i64 3
  %19 = bitcast i32** %18 to i8**
  store i8* %17, i8** %19, align 8, !tbaa !10
  %20 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %21 = getelementptr inbounds i32*, i32** %9, i64 4
  %22 = bitcast i32** %21 to i8**
  store i8* %20, i8** %22, align 8, !tbaa !10
  %23 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %24 = getelementptr inbounds i32*, i32** %9, i64 5
  %25 = bitcast i32** %24 to i8**
  store i8* %23, i8** %25, align 8, !tbaa !10
  %26 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %27 = getelementptr inbounds i32*, i32** %9, i64 6
  %28 = bitcast i32** %27 to i8**
  store i8* %26, i8** %28, align 8, !tbaa !10
  %29 = tail call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %30 = getelementptr inbounds i32*, i32** %9, i64 7
  %31 = bitcast i32** %30 to i8**
  store i8* %29, i8** %31, align 8, !tbaa !10
  %32 = tail call i32 @go(i32 noundef 1, i32 noundef 2, i32 noundef 0)
  ret i32 0
}

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0)
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #5

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0,1)
declare noalias noundef i8* @calloc(i64 noundef, i64 noundef) local_unnamed_addr #6

; Function Attrs: nofree nounwind
declare noundef i32 @putchar(i32 noundef) local_unnamed_addr #7

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.abs.i32(i32, i1 immarg) #8

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #2 = { nofree nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind readonly ssp willreturn uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #4 = { noreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #5 = { inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #6 = { inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0,1) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #7 = { nofree nounwind }
attributes #8 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #9 = { nounwind }
attributes #10 = { noreturn nounwind }
attributes #11 = { allocsize(0) }
attributes #12 = { allocsize(0,1) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 13, i32 3]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"branch-target-enforcement", i32 0}
!3 = !{i32 8, !"sign-return-address", i32 0}
!4 = !{i32 8, !"sign-return-address-all", i32 0}
!5 = !{i32 8, !"sign-return-address-with-bkey", i32 0}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{i32 7, !"uwtable", i32 1}
!8 = !{i32 7, !"frame-pointer", i32 1}
!9 = !{!"Apple clang version 14.0.3 (clang-1403.0.22.14.1)"}
!10 = !{!11, !11, i64 0}
!11 = !{!"any pointer", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = !{!15, !15, i64 0}
!15 = !{!"int", !12, i64 0}
!16 = distinct !{!16, !17}
!17 = !{!"llvm.loop.mustprogress"}
!18 = distinct !{!18, !17}
