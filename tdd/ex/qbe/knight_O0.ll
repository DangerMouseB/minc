; ModuleID = 'knight.c'
source_filename = "knight.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

@N = global i32 0, align 4
@t = common global i64* null, align 8
@.str = private unnamed_addr constant [7 x i8] c"t: %s\0A\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c" %02d\00", align 1
@b = common global i32** null, align 8
@.str.2 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1



;; BOARD



; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @board() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = load i64*, i64** @t, align 8
  %4 = call i64 @time(i64* noundef %3)
  %5 = load i64*, i64** @t, align 8
  %6 = call i8* @ctime(i64* noundef %5)
  %7 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i64 0, i64 0), i8* noundef %6)
  store i32 0, i32* %2, align 4
  br label %8

8:                                                ; preds = %31, %0
  %9 = load i32, i32* %2, align 4
  %10 = icmp slt i32 %9, 8
  br i1 %10, label %11, label %34

11:                                               ; preds = %8
  store i32 0, i32* %1, align 4
  br label %12

12:                                               ; preds = %26, %11
  %13 = load i32, i32* %1, align 4
  %14 = icmp slt i32 %13, 8
  br i1 %14, label %15, label %29

15:                                               ; preds = %12
  %16 = load i32**, i32*** @b, align 8
  %17 = load i32, i32* %1, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds i32*, i32** %16, i64 %18
  %20 = load i32*, i32** %19, align 8
  %21 = load i32, i32* %2, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds i32, i32* %20, i64 %22
  %24 = load i32, i32* %23, align 4
  %25 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %24)
  br label %26

26:                                               ; preds = %15
  %27 = load i32, i32* %1, align 4
  %28 = add nsw i32 %27, 1
  store i32 %28, i32* %1, align 4
  br label %12, !llvm.loop !10

29:                                               ; preds = %12
  %30 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([2 x i8], [2 x i8]* @.str.2, i64 0, i64 0))
  br label %31

31:                                               ; preds = %29
  %32 = load i32, i32* %2, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* %2, align 4
  br label %8, !llvm.loop !12

34:                                               ; preds = %8
  %35 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([2 x i8], [2 x i8]* @.str.2, i64 0, i64 0))
  ret i32 0
}

declare i64 @time(i64* noundef) #1

declare i32 @printf(i8* noundef, ...) #1

declare i8* @ctime(i64* noundef) #1



;; CHK



; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @chk(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  %6 = load i32, i32* %4, align 4
  %7 = icmp slt i32 %6, 0
  br i1 %7, label %17, label %8

8:                                                ; preds = %2
  %9 = load i32, i32* %4, align 4
  %10 = icmp sgt i32 %9, 7
  br i1 %10, label %17, label %11

11:                                               ; preds = %8
  %12 = load i32, i32* %5, align 4
  %13 = icmp slt i32 %12, 0
  br i1 %13, label %17, label %14

14:                                               ; preds = %11
  %15 = load i32, i32* %5, align 4
  %16 = icmp sgt i32 %15, 7
  br i1 %16, label %17, label %18

17:                                               ; preds = %14, %11, %8, %2
  store i32 0, i32* %3, align 4
  br label %30

18:                                               ; preds = %14
  %19 = load i32**, i32*** @b, align 8
  %20 = load i32, i32* %4, align 4
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds i32*, i32** %19, i64 %21
  %23 = load i32*, i32** %22, align 8
  %24 = load i32, i32* %5, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds i32, i32* %23, i64 %25
  %27 = load i32, i32* %26, align 4
  %28 = icmp eq i32 %27, 0
  %29 = zext i1 %28 to i32
  store i32 %29, i32* %3, align 4
  br label %30

30:                                               ; preds = %18, %17
  %31 = load i32, i32* %3, align 4
  ret i32 %31
}



;; GO



; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @go(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store i32 %0, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  store i32 %2, i32* %6, align 4
  %9 = load i32, i32* %4, align 4
  %10 = load i32**, i32*** @b, align 8
  %11 = load i32, i32* %5, align 4
  %12 = sext i32 %11 to i64
  %13 = getelementptr inbounds i32*, i32** %10, i64 %12
  %14 = load i32*, i32** %13, align 8
  %15 = load i32, i32* %6, align 4
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds i32, i32* %14, i64 %16
  store i32 %9, i32* %17, align 4
  %18 = load i32, i32* %4, align 4
  %19 = icmp eq i32 %18, 64
  br i1 %19, label %20, label %43

20:                                               ; preds = %3
  %21 = load i32, i32* %5, align 4
  %22 = icmp ne i32 %21, 2
  br i1 %22, label %23, label %42

23:                                               ; preds = %20
  %24 = load i32, i32* %6, align 4
  %25 = icmp ne i32 %24, 0
  br i1 %25, label %26, label %42

26:                                               ; preds = %23
  %27 = load i32, i32* %5, align 4
  %28 = sub nsw i32 %27, 2
  %29 = call i32 @abs(i32 noundef %28) #6
  %30 = load i32, i32* %6, align 4
  %31 = call i32 @abs(i32 noundef %30) #6
  %32 = add nsw i32 %29, %31
  %33 = icmp eq i32 %32, 3
  br i1 %33, label %34, label %42

34:                                               ; preds = %26
  %35 = call i32 @board()
  %36 = load i32, i32* @N, align 4
  %37 = add nsw i32 %36, 1
  store i32 %37, i32* @N, align 4
  %38 = load i32, i32* @N, align 4
  %39 = icmp eq i32 %38, 10
  br i1 %39, label %40, label %41

40:                                               ; preds = %34
  call void @exit(i32 noundef 0) #7
  unreachable

41:                                               ; preds = %34
  br label %42

42:                                               ; preds = %41, %26, %23, %20
  br label %86

43:                                               ; preds = %3
  store i32 -2, i32* %7, align 4
  br label %44

44:                                               ; preds = %82, %43
  %45 = load i32, i32* %7, align 4
  %46 = icmp sle i32 %45, 2
  br i1 %46, label %47, label %85

47:                                               ; preds = %44
  store i32 -2, i32* %8, align 4
  br label %48

48:                                               ; preds = %78, %47
  %49 = load i32, i32* %8, align 4
  %50 = icmp sle i32 %49, 2
  br i1 %50, label %51, label %81

51:                                               ; preds = %48
  %52 = load i32, i32* %7, align 4
  %53 = call i32 @abs(i32 noundef %52) #6
  %54 = load i32, i32* %8, align 4
  %55 = call i32 @abs(i32 noundef %54) #6
  %56 = add nsw i32 %53, %55
  %57 = icmp eq i32 %56, 3
  br i1 %57, label %58, label %77

58:                                               ; preds = %51
  %59 = load i32, i32* %5, align 4
  %60 = load i32, i32* %7, align 4
  %61 = add nsw i32 %59, %60
  %62 = load i32, i32* %6, align 4
  %63 = load i32, i32* %8, align 4
  %64 = add nsw i32 %62, %63
  %65 = call i32 @chk(i32 noundef %61, i32 noundef %64)
  %66 = icmp ne i32 %65, 0
  br i1 %66, label %67, label %77

67:                                               ; preds = %58
  %68 = load i32, i32* %4, align 4
  %69 = add nsw i32 %68, 1
  %70 = load i32, i32* %5, align 4
  %71 = load i32, i32* %7, align 4
  %72 = add nsw i32 %70, %71
  %73 = load i32, i32* %6, align 4
  %74 = load i32, i32* %8, align 4
  %75 = add nsw i32 %73, %74
  %76 = call i32 @go(i32 noundef %69, i32 noundef %72, i32 noundef %75)
  br label %77

77:                                               ; preds = %67, %58, %51
  br label %78

78:                                               ; preds = %77
  %79 = load i32, i32* %8, align 4
  %80 = add nsw i32 %79, 1
  store i32 %80, i32* %8, align 4
  br label %48, !llvm.loop !13

81:                                               ; preds = %48
  br label %82

82:                                               ; preds = %81
  %83 = load i32, i32* %7, align 4
  %84 = add nsw i32 %83, 1
  store i32 %84, i32* %7, align 4
  br label %44, !llvm.loop !14

85:                                               ; preds = %44
  br label %86

86:                                               ; preds = %85, %42
  %87 = load i32**, i32*** @b, align 8
  %88 = load i32, i32* %5, align 4
  %89 = sext i32 %88 to i64
  %90 = getelementptr inbounds i32*, i32** %87, i64 %89
  %91 = load i32*, i32** %90, align 8
  %92 = load i32, i32* %6, align 4
  %93 = sext i32 %92 to i64
  %94 = getelementptr inbounds i32, i32* %91, i64 %93
  store i32 0, i32* %94, align 4
  ret i32 0
}

; Function Attrs: nounwind readnone willreturn
declare i32 @abs(i32 noundef) #2

; Function Attrs: noreturn
declare void @exit(i32 noundef) #3



;; MAIN



; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %3 = call i8* @malloc(i64 noundef 8) #8
  %4 = bitcast i8* %3 to i64*
  store i64* %4, i64** @t, align 8
  %5 = load i64*, i64** @t, align 8
  %6 = call i64 @time(i64* noundef %5)
  %7 = load i64*, i64** @t, align 8
  %8 = call i8* @ctime(i64* noundef %7)
  %9 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i64 0, i64 0), i8* noundef %8)
  %10 = call i8* @calloc(i64 noundef 8, i64 noundef 8) #9
  %11 = bitcast i8* %10 to i32**
  store i32** %11, i32*** @b, align 8
  store i32 0, i32* %2, align 4
  br label %12

12:                                               ; preds = %22, %0
  %13 = load i32, i32* %2, align 4
  %14 = icmp slt i32 %13, 8
  br i1 %14, label %15, label %25

15:                                               ; preds = %12
  %16 = call i8* @calloc(i64 noundef 8, i64 noundef 4) #9
  %17 = bitcast i8* %16 to i32*
  %18 = load i32**, i32*** @b, align 8
  %19 = load i32, i32* %2, align 4
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds i32*, i32** %18, i64 %20
  store i32* %17, i32** %21, align 8
  br label %22

22:                                               ; preds = %15
  %23 = load i32, i32* %2, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %2, align 4
  br label %12, !llvm.loop !15

25:                                               ; preds = %12
  %26 = call i32 @go(i32 noundef 1, i32 noundef 2, i32 noundef 0)
  %27 = load i32, i32* %1, align 4
  ret i32 %27
}

; Function Attrs: allocsize(0)
declare i8* @malloc(i64 noundef) #4

; Function Attrs: allocsize(0,1)
declare i8* @calloc(i64 noundef, i64 noundef) #5

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #2 = { nounwind readnone willreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #3 = { noreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #4 = { allocsize(0) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #5 = { allocsize(0,1) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #6 = { nounwind readnone willreturn }
attributes #7 = { noreturn }
attributes #8 = { allocsize(0) }
attributes #9 = { allocsize(0,1) }

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
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.mustprogress"}
!12 = distinct !{!12, !11}
!13 = distinct !{!13, !11}
!14 = distinct !{!14, !11}
!15 = distinct !{!15, !11}
